//
//  RSSFeedsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/14/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "RSSFeedsViewController.h"
#import "OpenStackAccount.h"
#import "Provider.h"
#import "RSSFeedViewController.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"

@implementation RSSFeedsViewController

@synthesize account, comingFromAccountHome;

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"System Status";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && comingFromAccountHome) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        comingFromAccountHome = NO;
    }
    loaded = YES;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.account.provider.rssFeeds count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *feed = [self.account.provider.rssFeeds objectAtIndex:indexPath.row];
    if ([[feed objectForKey:@"name"] isEqualToString:@"Cloud Servers Status"]) {
        cell.textLabel.text = @"Cloud Servers";
    } else if ([[feed objectForKey:@"name"] isEqualToString:@"Cloud Files Status"]) {
        cell.textLabel.text = @"Cloud Files";
    } else {
        cell.textLabel.text = [feed objectForKey:@"name"];
    }
    
    
    if ([feed objectForKey:@"logo"]) {
        cell.imageView.image = [UIImage imageNamed:[feed objectForKey:@"logo"]];
    } else {
        cell.imageView.image = nil;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSFeedViewController *vc = [[RSSFeedViewController alloc] initWithNibName:@"RSSFeedViewController" bundle:nil];
    vc.feed = [self.account.provider.rssFeeds objectAtIndex:indexPath.row];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (loaded) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            if (app.rootViewController.popoverController != nil) {
                [app.rootViewController.popoverController dismissPopoverAnimated:YES];
            }
        }
        [self presentPrimaryViewController:vc];
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    [vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [account release];
    [super dealloc];
}


@end

