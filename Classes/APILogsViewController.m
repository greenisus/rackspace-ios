//
//  APILogsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "APILogsViewController.h"
#import "OpenStackAccount.h"
#import "APILogger.h"
#import "APILogEntry.h"
#import "UIViewController+Conveniences.h"
#import "ActivityIndicatorView.h"
#import "LogEntryViewController.h"


@implementation APILogsViewController

@synthesize account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Button Handlers

- (void)refreshButtonPressed:(id)sender {
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Loading..."] text:@"Loading..."];
    [activityIndicatorView addToView:self.view];
    
    loggerEntries = [APILogger loggerEntries];
    
    [activityIndicatorView removeFromSuperviewAndRelease];
    entriesLoaded = YES;
    [self.tableView reloadData];    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"API Logs";
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshButtonPressed:nil];
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
    return entriesLoaded ? [loggerEntries count] : 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    
    APILogEntry *entry = [loggerEntries objectAtIndex:indexPath.row];    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", entry.requestMethod, [entry.url path]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", entry.responseStatusMessage];
    
    if (entry.responseStatusCode == 0) {
        cell.detailTextLabel.text = @"No response";
    }
    
    if (entry.responseStatusCode < 200 || entry.responseStatusCode >= 300) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LogEntryViewController *vc = [[LogEntryViewController alloc] initWithNibName:@"LogEntryViewController" bundle:nil];
    vc.logEntry = [loggerEntries objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
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

