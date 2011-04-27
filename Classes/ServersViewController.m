//
//  ServersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServersViewController.h"
#import "OpenStackAccount.h"
#import "AddServerViewController.h"
#import "UIViewController+Conveniences.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "ServerViewController.h"
#import "OpenStackRequest.h"
#import "RateLimit.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"
#import "AccountHomeViewController.h"
#import "AccountManager.h"
#import "Reachability.h"
#import "Provider.h"


@implementation ServersViewController

@synthesize tableView, account, accountHomeViewController, comingFromAccountHome;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Button Handlers

- (void)addButtonPressed:(id)sender {
    RateLimit *limit = [OpenStackRequest createServerLimit:self.account];
    if (!limit || limit.remaining > 0) {
        AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServerViewController" bundle:nil];
        vc.account = account;
        vc.serversViewController = self;
        vc.accountHomeViewController = self.accountHomeViewController;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
        [self presentModalViewControllerWithNavigation:vc];
        [vc release];
    } else {
        [self alert:@"API Rate Limit Reached" message:@"You have reached your API rate limit for creating servers in this account.  Please try again when your limit has been reset."];
    }
}

- (void)selectFirstServer {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)refreshButtonPressed:(id)sender {

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == kNotReachable) {
        [self failOnBadConnection];
    } else {
        BOOL hadZeroServers = [self.account.servers count] == 0;
        
        refreshButton.enabled = NO;
        [self showToolbarActivityMessage:@"Refreshing servers..."];
        [self.account.manager getServers];
        
        getServersSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getServersSucceeded" object:self.account 
                                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
                                       {
                                           [self.account persist];
                                           refreshButton.enabled = YES;
                                           [self hideToolbarActivityMessage];
                                           if (!hadZeroServers && [self.account.servers count] > 0) {
                                               [self.tableView reloadData];
                                           }
                                           if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                               [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(selectFirstServer) userInfo:nil repeats:NO];
                                           }
                                           [[NSNotificationCenter defaultCenter] removeObserver:getServersSucceededObserver];
                                       }];
        
        getServersFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getServersFailed" object:self.account 
                                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
                                    {
                                        refreshButton.enabled = YES;
                                        [self hideToolbarActivityMessage];
                                        [self alert:@"There was a problem loading your servers." request:[notification.userInfo objectForKey:@"request"]];
                                        [[NSNotificationCenter defaultCenter] removeObserver:getServersFailedObserver];
                                    }];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [self.account.provider isRackspace] ? @"Cloud Servers" : @"Compute";
    [self addAddButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        loaded = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self showToolbarActivityMessage:@"This is a test..."];
        
    // Let's register for server rename notifications so we can keep the names fresh.
    // We'll only register for successful renames since a failure isn't relevant in the
    // list context.
    renameServerSucceededObservers = [[NSMutableDictionary alloc] initWithCapacity:[account.servers count]];
    
    NSEnumerator *enumerator = [account.servers keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        Server *server = [account.servers objectForKey:key];
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"renameServerSucceeded" object:server
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                       {
                           [self.tableView reloadData];                           
                           [[NSNotificationCenter defaultCenter] removeObserver:[renameServerSucceededObservers objectForKey:[NSNumber numberWithInt:server.identifier]]];
                       }];
        [renameServerSucceededObservers setObject:observer forKey:key];
    }
    
    getImageSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getImageSucceeded" object:nil
                                                                                   queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
      {
          for (Server *server in self.account.sortedServers) {
              BOOL updated = NO;
              if (!server.image) {
                  server.image = [self.account.images objectForKey:[NSNumber numberWithInt:server.imageId]];
                  updated = YES;
              }
              if (updated) {
                  [self.tableView reloadData];
              }
          }         
      }];
    
    getImageFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getImageFailed" object:nil
                                                                                queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
      {
          NSLog(@"loading image failed");
      }];
    
    if ([self.account.servers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // remove rename observers
    NSEnumerator *enumerator = [renameServerSucceededObservers keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        [[NSNotificationCenter defaultCenter] removeObserver:[renameServerSucceededObservers objectForKey:key]];
    }    

    // TODO: unregister for "createServerSucceeded"
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.account.servers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.allowsSelection = YES;
        self.tableView.scrollEnabled = YES;
    }
    return MAX(1, [account.sortedServers count]);
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([account.servers count] == 0) {
        return aTableView.frame.size.height;
    } else {
        return aTableView.rowHeight;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    if ([account.servers count] == 0) {
        return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-servers.png"] title:@"No Servers" subtitle:@"Tap the + button to create a new Cloud Server"];
    } else {
        static NSString *CellIdentifier = @"Cell";

        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        // Configure the cell...
        Server *server = [account.sortedServers objectAtIndex:indexPath.row];
        
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = server.flavor.name;
        
        if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
            cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
        }
        
        return cell;
    }    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Server *server = nil;
    if ([account.servers count] > 0) {
        server = [account.sortedServers objectAtIndex:indexPath.row];
    }
    ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    vc.server = server;
    vc.account = account;
    vc.serversViewController = self;
    vc.selectedServerIndexPath = indexPath;
    vc.accountHomeViewController = self.accountHomeViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentPrimaryViewController:vc];
        if (loaded) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController != nil) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    [vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [tableView release];
    [account release];
    [accountHomeViewController release];
    [super dealloc];
}


@end

