//
//  LBNodesViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBNodesViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "LoadBalancerNode.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"

#define kNodes 0
#define kCloudServers 1

@implementation LBNodesViewController

@synthesize account, loadBalancer;

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Nodes";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kNodes) {
        return [self.loadBalancer.nodes count] + 1;
    } else {
        return 1; //[self.account.servers count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.section == kNodes) {
        cell.textLabel.text = @"Add Nodes by IP";
        cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
    } else if (indexPath.section == kCloudServers) {
        cell.textLabel.text = @"Add Cloud Servers";
        cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
        /*
        Server *server = [self.account.sortedServers objectAtIndex:indexPath.row];
        cell.textLabel.text = server.name;
        cell.detailTextLabel.text = server.flavor.name;
        if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
            cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
        }
         */
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == kNodes && indexPath.row == [self.loadBalancer.nodes count];
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
