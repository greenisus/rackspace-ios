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
#import "RSTextFieldCell.h"

#define kNodes 0
#define kCloudServers 1

@implementation LBNodesViewController

@synthesize account, loadBalancer;

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [textFieldIndexPaths release];
    [indexPathTextFields release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Nodes";
    textFieldIndexPaths = [[NSMutableDictionary alloc] init];
    indexPathTextFields = [[NSMutableDictionary alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kNodes) {
        NSLog(@"rows: %i", [self.loadBalancer.nodes count] + 1);
        return [self.loadBalancer.nodes count] + 1;
    } else {
        return 1; //[self.account.servers count] + 1;
    }
}

- (RSTextFieldCell *)tableView:(UITableView *)tableView ipCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"IPCell%i", indexPath.row];
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textField.delegate = self;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    
    if ([indexPathTextFields count] <= indexPath.row) {
        [cell.textField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [textFieldIndexPaths setObject:indexPath forKey:cell.textField];
    [indexPathTextFields setObject:cell.textField forKey:indexPath];
    
//    if ([textFields count] < indexPath.row) {
//        [textFields replaceObjectAtIndex:indexPath.row withObject:cell.textField];
//    } else {
//        [textFields addObject:cell.textField];
//    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.section == kNodes) {
        if (indexPath.row == [self.loadBalancer.nodes count]) {
            cell.textLabel.text = @"Add IP Addresses";
            cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
        } else {
            return [self tableView:tableView ipCellForRowAtIndexPath:indexPath];
        }
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

- (void)addIPRow {
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    [self.loadBalancer.nodes addObject:node];
    NSArray *indexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.loadBalancer.nodes count] - 1 inSection:kNodes]];
    [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewScrollPositionBottom];
    //[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodes) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self addIPRow];
    }
}

#pragma mark - Text field delegate

//- (void)refreshFocus:(NSTimer *)timer {
//    [[indexPathTextFields objectForKey:[timer.userInfo objectForKey:@"indexPath"]] becomeFirstResponder];
//}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self addIPRow];
    
//    NSIndexPath *indexPath = [textFieldIndexPaths objectForKey:textField];    
//    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:kNodes];
//
//    NSLog(@"indexPaths: %i to %i", indexPath.row, newIndexPath.row);
    
    //[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshFocus:) userInfo:[NSDictionary dictionaryWithObject:newIndexPath forKey:@"indexPath"] repeats:NO];
    
    //[[indexPathTextFields objectForKey:newIndexPath] becomeFirstResponder];
    
    //RSTextFieldCell *cell = [self tableView:self.tableView ipCellForRowAtIndexPath:newIndexPath];
    //[textField resignFirstResponder];
    //NSLog(@"%i cell: %@ %@", [self.loadBalancer.nodes count] - 1, cell, cell.textField);
    //[cell.textField becomeFirstResponder];
    //[NSTimer scheduledTimerWithTimeInterval:0.4 target:cell.textField selector:@selector(becomeFirstResponder) userInfo:nil repeats:NO];
    
    //[[textFields objectAtIndex:indexPath.row] becomeFirstResponder];

    
    
    return NO;
}

@end
