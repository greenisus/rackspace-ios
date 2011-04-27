//
//  ServersOnHostViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServersOnHostViewController.h"
#import "ServerViewController.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"


@implementation ServersOnHostViewController

@synthesize tableView, account, servers, hostID;

- (void)dealloc {
    [tableView release];
    [account release];
    [servers release];
    [hostID release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Servers on Host";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.servers count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"These Cloud Servers are all located on the same physical host machine.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    Server *server = [self.servers objectAtIndex:indexPath.row];
    cell.textLabel.text = server.name;
    cell.detailTextLabel.text = server.flavor.name;
    if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
        cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    Server *server = [self.servers objectAtIndex:indexPath.row];
    ServerViewController *vc = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    vc.server = server;
    vc.account = account;
    vc.serversViewController = nil;
    vc.selectedServerIndexPath = indexPath;
    vc.accountHomeViewController = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self presentPrimaryViewController:vc];
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        if (app.rootViewController.popoverController != nil) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    [vc release];
     */
}

@end
