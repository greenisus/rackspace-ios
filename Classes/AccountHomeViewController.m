//
//  AccountHomeViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountHomeViewController.h"
#import "OpenStackAccount.h"
#import "Provider.h"
#import "ContactInformationViewController.h"
#import "APILogsViewController.h"
#import "ServersViewController.h"
#import "NSObject+Conveniences.h"
#import "RootViewController.h"
#import "LimitsViewController.h"
#import "Container.h"
#import "ContainersViewController.h"
#import "AccountManager.h"
#import "AccountSettingsViewController.h"
#import "RSSFeedsViewController.h"
#import "UIViewController+Conveniences.h"
#import "Keychain.h"
#import "PasscodeViewController.h"
#import "OpenStackAppDelegate.h"
#import "LoadBalancersViewController.h"
#import "Reachability.h"


@implementation AccountHomeViewController

@synthesize account, rootViewController, rootViewIndexPath, tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)incrementRefreshCount {
    refreshCount++;
    if (refreshCount == 2) {
        self.account.hasBeenRefreshed = YES;
        [self hideToolbarActivityMessage];
        refreshButton.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // observe getImagesFailed?
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == kNotReachable) {
        self.account.hasBeenRefreshed = YES;
        [self hideToolbarActivityMessage];
        refreshButton.enabled = YES;
        [self failOnBadConnection];
    }
    
    authRetryFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"authRetryFailed" identifier:0] object:nil
                                                                               queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self hideToolbarActivityMessage];
        [self alert:@"Authentication failed.  Please check your username and API key." request:[notification.userInfo objectForKey:@"request"]];
        [[NSNotificationCenter defaultCenter] removeObserver:authRetryFailedObserver];
    }];    
    
    id getServersObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getServersSucceeded" object:self.account 
                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:computeRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self incrementRefreshCount];
    }];
    
    id getServersFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getServersFailed" object:self.account 
                                                                               queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self incrementRefreshCount];
    }];

    id getContainersObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getContainersSucceeded" object:self.account 
                                                                              queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:storageRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self incrementRefreshCount];
    }];
    id getContainersFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getContainersFailed" object:self.account 
                                                                                  queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self incrementRefreshCount];
    }];
    id getLoadBalancersObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getLoadBalancersSucceeded" object:self.account 
                                                                                     queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        if (loadBalancingRow > 0) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:loadBalancingRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self incrementRefreshCount];
        }
    }];
    id createServerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"createServerSucceeded" object:self.account 
                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:computeRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    id createContainerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"createContainerSucceeded" object:self.account 
                                                                              queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:storageRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    id deleteServerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteServerSucceeded" object:self.account 
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:computeRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    id deleteContainerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteContainerSucceeded" object:self.account 
                                                                                    queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:storageRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    observers = [[NSArray alloc] initWithObjects:getServersObserver, getServersFailedObserver, getContainersObserver, getContainersFailedObserver, createServerObserver, createContainerObserver, deleteServerObserver, deleteContainerObserver, getLoadBalancersObserver, nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = self.account.username;    
    
    totalRows = 0;
    computeRow = (self.account.serversURL && [self.account.serversURL host]) ? totalRows++ : -1;
    storageRow = (self.account.filesURL && [self.account.filesURL host]) ? totalRows++ : -1;
    loadBalancingRow = [self.account loadBalancerURLs] ? totalRows++ : -1;

    if (self.account.provider.rssFeeds && [self.account.provider.rssFeeds count] > 0) {
        rssFeedsRow = totalRows++;
    } else {
        rssFeedsRow = -1;
    }
    if (self.account.provider.contactURLs && [self.account.provider.contactURLs count] > 0) {
        contactRow = totalRows++;
    } else {
        contactRow = -1;
    }
    limitsRow = totalRows++;
    accountSettingsRow = totalRows++;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.account.hasBeenRefreshed) {
        [self showToolbarActivityMessage:@"Refreshing data..."];
        [self.account refreshCollections];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [rootViewController.tableView deselectRowAtIndexPath:rootViewIndexPath animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    for (id observer in observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:authRetryFailedObserver];

    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return totalRows;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.imageView.image = nil;
    
    if (indexPath.row == computeRow) {
        cell.textLabel.text = [self.account.provider isRackspace] ? @"Cloud Servers" : @"Compute";
        cell.detailTextLabel.text = [NSObject pluralizedStringForDictionary:account.servers noun:@"Server"];
        cell.imageView.image = [self.account.provider isRackspace] ? [UIImage imageNamed:@"cloud-servers-icon.png"] : [UIImage imageNamed:@"openstack-icon.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == storageRow) {
        cell.textLabel.text = [self.account.provider isRackspace] ? @"Cloud Files" : @"Object Storage";
        if (self.account.containerCount == 1) {
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"1 Container, %@", [Container humanizedBytes:self.account.totalBytesUsed]];
            cell.detailTextLabel.text = @"1 Container";
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Containers", self.account.containerCount];
        }
        cell.imageView.image = [self.account.provider isRackspace] ? [UIImage imageNamed:@"cloud-files-icon.png"] : [UIImage imageNamed:@"openstack-icon.png"];
    } else if (indexPath.row == loadBalancingRow) {
        cell.textLabel.text = @"Load Balancers";
        cell.detailTextLabel.text = [NSObject pluralizedStringForArray:account.sortedLoadBalancers noun:@"Load Balancer"];
        cell.imageView.image = [UIImage imageNamed:@"load-balancers-icon.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == rssFeedsRow) {
        cell.textLabel.text = @"System Status";
        cell.detailTextLabel.text = [NSObject pluralizedStringForArray:account.provider.rssFeeds noun:@"Feed"];
        cell.imageView.image = [UIImage imageNamed:@"rss-feeds-icon.png"];
    } else if (indexPath.row == contactRow) {
        cell.textLabel.text = @"Fanatical Support"; // @"Contact Information";
        cell.imageView.image = [UIImage imageNamed:@"contact-rackspace-icon.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
//    } else if (indexPath.row == kAPILogs) {
//        cell.textLabel.text = @"API Logs";
    } else if (indexPath.row == limitsRow) {
        cell.textLabel.text = @"API Rate Limits";
        cell.imageView.image = [UIImage imageNamed:@"api-rate-limits-icon.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.row == accountSettingsRow) {
        cell.textLabel.text = @"API Account Info";
        cell.imageView.image = [UIImage imageNamed:@"account-settings-icon.png"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:aTableView didSelectRowAtIndexPath:indexPath];
    
    OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
    BOOL shouldHidePopover = NO;
    if (indexPath.row == computeRow) {
        ServersViewController *vc = [[ServersViewController alloc] initWithNibName:@"ServersViewController" bundle:nil];
        vc.account = account;
        vc.accountHomeViewController = self;
        vc.comingFromAccountHome = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == storageRow) {
        ContainersViewController *vc = [[ContainersViewController alloc] initWithNibName:@"ContainersViewController" bundle:nil];
        vc.account = account;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == rssFeedsRow) {
        RSSFeedsViewController *vc = [[RSSFeedsViewController alloc] initWithNibName:@"RSSFeedsViewController" bundle:nil];
        vc.account = account;
        vc.comingFromAccountHome = YES;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == contactRow) {
        NSString *nibName = @"ContactInformationViewController";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nibName = @"ContactInformationViewController-iPad";
        }
        ContactInformationViewController *vc = [[ContactInformationViewController alloc] initWithNibName:nibName bundle:nil];
        vc.provider = account.provider;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController presentPrimaryViewController:vc];
            shouldHidePopover = YES;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        [vc release];
//    } else if (indexPath.row == kAPILogs) {
//        APILogsViewController *vc = [[APILogsViewController alloc] initWithNibName:@"APILogsViewController" bundle:nil];
//        vc.account = account;
//        [self.navigationController pushViewController:vc animated:YES];
//        [vc release];
    } else if (indexPath.row == limitsRow) {
        LimitsViewController *vc = [[LimitsViewController alloc] initWithNibName:@"LimitsViewController" bundle:nil];
        vc.account = account;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController presentPrimaryViewController:vc];
            shouldHidePopover = YES;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        [vc release];
    } else if (indexPath.row == accountSettingsRow) {
        AccountSettingsViewController *vc = [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
        vc.account = account;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController presentPrimaryViewController:vc];
            shouldHidePopover = YES;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        [vc release];
    } else if (indexPath.row == loadBalancingRow) {
        LoadBalancersViewController *vc = [[LoadBalancersViewController alloc] initWithNibName:@"LoadBalancersViewController" bundle:nil];
        vc.account = account;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController presentPrimaryViewController:vc];
            shouldHidePopover = YES;
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
        [vc release];
    }
    
    if (shouldHidePopover) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && app.rootViewController.popoverController != nil) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark Button Handlers

- (void)refreshButtonPressed:(id)sender {
    refreshButton.enabled = NO;
    refreshCount = 0;
    [self showToolbarActivityMessage:@"Refreshing data..."];
    [self.account refreshCollections];    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [rootViewController release];
    [observers release];
    [tableView release];
    [super dealloc];
}

@end
