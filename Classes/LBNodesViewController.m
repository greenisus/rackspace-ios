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
#import "UIViewController+Conveniences.h"
#import "LBServersViewController.h"
#import "LoadBalancerProtocol.h"

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
    textFields = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kNodes) {
        return [self.loadBalancer.nodes count] + 1;
    } else {
        return [self.loadBalancer.cloudServerNodes count] + 1;
    }
}

- (RSTextFieldCell *)tableView:(UITableView *)tableView ipCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"IPCell%i", indexPath.row];
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textField.delegate = self;
        
        // tag it so we'll know which node we're editing
        cell.textField.tag = indexPath.row;
        
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [textFields addObject:cell.textField];
    }

//    if ([textFields count] <= indexPath.row) {
//        [cell.textField becomeFirstResponder];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self addDoneButton];
//    }
        
    if (indexPath.row < [self.loadBalancer.nodes count]) {
        LoadBalancerNode *node = [self.loadBalancer.nodes objectAtIndex:indexPath.row];
        cell.textField.text = node.address;
    }
    
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
        if (indexPath.row == [self.loadBalancer.cloudServerNodes count]) {
            cell.textLabel.text = @"Add Cloud Servers";
            cell.imageView.image = [UIImage imageNamed:@"green-add-button.png"];
        } else {
            Server *server = [self.loadBalancer.cloudServerNodes objectAtIndex:indexPath.row];
            cell.textLabel.text = server.name;
            cell.detailTextLabel.text = server.flavor.name;
            if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
                cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
            }
        }
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

- (void)focusOnLastTextField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[textFields count] - 1 inSection:kNodes];
    [[textFields lastObject] becomeFirstResponder];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self addDoneButton];
}

- (void)addIPRow {
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    node.condition = @"ENABLED";
    node.port = [NSString stringWithFormat:@"%i", self.loadBalancer.protocol.port];
    [self.loadBalancer.nodes addObject:node];
    NSArray *indexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.loadBalancer.nodes count] - 1 inSection:kNodes]];
    [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewScrollPositionBottom];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(focusOnLastTextField) userInfo:nil repeats:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodes) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self addIPRow];
    } else if (indexPath.section == kCloudServers) {
        LBServersViewController *vc = [[LBServersViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self presentModalViewControllerWithNavigation:vc];
        [vc release];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self addDoneButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self addIPRow];    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {    
    LoadBalancerNode *node = [self.loadBalancer.nodes objectAtIndex:textField.tag];    
    node.address = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (void)doneButtonPressed:(id)sender {
    for (UITextField *textField in textFields) {
        [textField resignFirstResponder];
    }
    self.navigationItem.rightBarButtonItem = nil;
}

@end
