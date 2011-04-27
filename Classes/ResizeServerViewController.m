//
//  ResizeServerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ResizeServerViewController.h"
#import "ServerViewController.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackAccount.h"
#import "Server.h"
#import "Flavor.h"
#import "AccountManager.h"
#import "Provider.h"

@implementation ResizeServerViewController

@synthesize account, server;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
    [self.account.manager resizeServer:self.server flavor:selectedFlavor];
    [serverViewController showToolbarActivityMessage:@"Resizing server..."];
    [self dismissModalViewControllerAnimated:YES];    
    [serverViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kResize inSection:kActions] animated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    selectedFlavor = self.server.flavor;
    [tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.account.flavors count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [self.account.provider isRackspace] ? @"Resizes will be charged or credited a prorated amount based upon the difference in cost and the number of days remaining in your billing cycle." : @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    Flavor *flavor = [self.account.sortedFlavors objectAtIndex:indexPath.row];
	cell.textLabel.text = flavor.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
	
	if (flavor.identifier == selectedFlavor.identifier) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedFlavor = [self.account.sortedFlavors objectAtIndex:indexPath.row];    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[account release];
    [server release];
    [super dealloc];
}

@end

