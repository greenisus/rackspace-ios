//
//  ContainersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ContainersViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "AddContainerViewController.h"
#import "UIViewController+Conveniences.h"
#import "FolderViewController.h"
#import "ContainerDetailViewController.h"
#import "AccountManager.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"
#import "Reachability.h"


@implementation ContainersViewController

@synthesize tableView, account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Containers";
    [self addAddButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"createContainerSucceeded" object:self.account 
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
       {
           [self hideToolbarActivityMessage];
           [self.tableView reloadData];
       }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"createContainerFailed" object:self.account 
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
       {
           [self hideToolbarActivityMessage];
           [self alert:@"There was a problem creating your container." request:[notification.userInfo objectForKey:@"request"]];
       }];
    
    if ([self.account.containers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
        [self.tableView reloadData];        
    }    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self.account.containers count] == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
}

#pragma mark -
#pragma mark Button Handlers

- (void)addButtonPressed:(id)sender {
    AddContainerViewController *vc = [[AddContainerViewController alloc] initWithNibName:@"AddContainerViewController" bundle:nil];
    vc.containersViewController = self;
    vc.account = account;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        if (app.rootViewController.popoverController != nil) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }                
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
}

- (void)refreshButtonPressed:(id)sender {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == kNotReachable) {
        [self failOnBadConnection];
    } else {
        refreshButton.enabled = NO;
        
        BOOL hadZeroContainers = [self.account.containers count] == 0;
        
        refreshButton.enabled = NO;
        [self showToolbarActivityMessage:@"Refreshing containers..."];
        [self.account.manager getContainers];
        
        getContainersSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getContainersSucceeded" object:self.account 
                                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            refreshButton.enabled = YES;
            [self hideToolbarActivityMessage];
            if (!hadZeroContainers && [self.account.containers count] > 0) {
                [self.tableView reloadData];
            }
            [[NSNotificationCenter defaultCenter] removeObserver:getContainersSucceededObserver];
        }];
        
        getContainersFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getContainersFailed" object:self.account 
                                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            refreshButton.enabled = YES;
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem loading your containers." request:[notification.userInfo objectForKey:@"request"]];
            [[NSNotificationCenter defaultCenter] removeObserver:getContainersFailedObserver];
        }];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.account.containers count] == 0) {
        self.tableView.allowsSelection = NO;
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.allowsSelection = YES;
        self.tableView.scrollEnabled = YES;
    }
    return MAX(1, [account.containers count]);    
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([account.containers count] == 0) {
        return aTableView.frame.size.height;
    } else {
        return aTableView.rowHeight;
    }
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([account.containers count] == 0) {
        return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-containers.png"] title:@"No Containers" subtitle:@"Tap the + button to create a new container"];
    } else {   
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
            cell.imageView.image = [UIImage imageNamed:@"folder-icon.png"];
        }

        Container *container = [self.account.sortedContainers objectAtIndex:indexPath.row];
        cell.textLabel.text = container.name;
        cell.detailTextLabel.text = [container humanizedSize];
        
        return cell;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Container *container = nil;
    if ([account.containers count] > 0) {
        container = [self.account.sortedContainers objectAtIndex:indexPath.row];

        FolderViewController *vc = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
        vc.account = self.account;
        vc.container = container;
        vc.folder = container.rootFolder;
        vc.containersViewController = self;
        vc.selectedContainerIndexPath = indexPath;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
        vc.account = self.account;
        vc.container = container;
        vc.containersViewController = self;
        vc.selectedContainerIndexPath = indexPath;
        [self presentPrimaryViewController:vc];
        [vc release];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Container *container = nil;
    if ([account.containers count] > 0) {
        container = [self.account.sortedContainers objectAtIndex:indexPath.row];
    }
    ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
    vc.account = self.account;
    vc.container = container;
    vc.containersViewController = self;
    vc.selectedContainerIndexPath = indexPath;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [tableView release];
    [account release];
    [super dealloc];
}

@end
