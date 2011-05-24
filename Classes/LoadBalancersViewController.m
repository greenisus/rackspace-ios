//
//  LoadBalancersViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancersViewController.h"
#import "OpenStackAccount.h"
#import "LoadBalancer.h"
#import "NSObject+Conveniences.h"
#import "UIViewController+Conveniences.h"
#import "LoadBalancerViewController.h"
#import "AddLoadBalancerViewController.h"


@implementation LoadBalancersViewController

@synthesize account, tableView, toolbar;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Load Balancers";
    [self addAddButton];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [self.account.sortedLoadBalancers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    LoadBalancer *loadBalancer = [self.account.sortedLoadBalancers objectAtIndex:indexPath.row];
    cell.textLabel.text = loadBalancer.name;
    if ([loadBalancer.nodes count] == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ to 1 node", loadBalancer.algorithm];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ to %i nodes", loadBalancer.algorithm, [loadBalancer.nodes count]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"load-balancers-icon.png"];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LoadBalancer *loadBalancer = [self.account.sortedLoadBalancers objectAtIndex:indexPath.row];
    LoadBalancerViewController *vc = [[LoadBalancerViewController alloc] initWithLoadBalancer:loadBalancer];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

#pragma - Button Handlers

- (void)addButtonPressed:(id)sender {
    AddLoadBalancerViewController *vc = [[AddLoadBalancerViewController alloc] initWithAccount:self.account];
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    self.tableView = nil;
    self.toolbar = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [account release];
    [tableView release];
    [toolbar release];
    [super dealloc];
}


@end

