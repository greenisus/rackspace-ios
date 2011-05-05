//
//  AddLoadBalancerNameViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"
#import "UIColor+MoreColors.h"
#import "AddLoadBalancerAlgorithmViewController.h"
#import "LoadBalancer.h"
#import "LBProtocolViewController.h"
#import "LBVirtualIPTypeViewController.h"
#import "AddLoadBalancerRegionViewController.h"
#import "LBAlgorithmViewController.h"
#import "Server.h"
#import "Flavor.h"
#import "Image.h"
#import "LoadBalancerNode.h"
#import "LBNodesViewController.h"
#import "LoadBalancerProtocol.h"

#define kDetailsSection 0
#define kNodesSection 1

#define kName 0
#define kProtocol 1
#define kVirtualIPType 2
#define kRegion 3
#define kAlgorithm 4

@implementation AddLoadBalancerViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerNameViewController" bundle:nil];
    if (self) {
        self.account = a;
        self.loadBalancer = [[LoadBalancer alloc] init];
        self.loadBalancer.virtualIPType = @"Public";
        self.loadBalancer.region = @"ORD";
        self.loadBalancer.algorithm = @"RANDOM";
        self.loadBalancer.protocol = [[LoadBalancerProtocol alloc] init];
        self.loadBalancer.protocol.name = @"HTTP";
        self.loadBalancer.protocol.port = 80;
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Load Balancer";
    //[self addNextButton];
    [self addSaveButton];
    [self addCancelButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if (section == kDetailsSection) {
        return 5;
    } else {
        return [self.loadBalancer.cloudServerNodes count] + [self.loadBalancer.nodes count] + 1;
    }
}

- (UITableViewCell *)nameCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"NameCell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Name";
        //cell.textField.placeholder = @"Ex: web-loadbalancer";
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kDetailsSection && indexPath.row == kName) {
        return [self nameCell:tableView];
    } else if (indexPath.section == kDetailsSection) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        switch (indexPath.row) {
            case kProtocol:
                cell.textLabel.text = @"Protocol";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%i", self.loadBalancer.protocol.name, self.loadBalancer.protocol.port];
                break;
            case kVirtualIPType:
                cell.textLabel.text = @"Virtual IP Type";
                cell.detailTextLabel.text = self.loadBalancer.virtualIPType;
                break;
            case kRegion:
                cell.textLabel.text = @"Region";
                cell.detailTextLabel.text = self.loadBalancer.region;
                break;
            case kAlgorithm:
                cell.textLabel.text = @"Algorithm";
                cell.detailTextLabel.text = self.loadBalancer.algorithm;
                break;
            default:
                break;
        }
        
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"NodeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        
        if (indexPath.row == [self.loadBalancer.cloudServerNodes count] + [self.loadBalancer.nodes count]) {
            cell.textLabel.text = @"Nodes";
            cell.detailTextLabel.text = @"5 Nodes";
        } else if (indexPath.row < [self.loadBalancer.cloudServerNodes count]) {
            Server *server = [self.loadBalancer.cloudServerNodes objectAtIndex:indexPath.row];
            cell.textLabel.text = server.name;
            cell.detailTextLabel.text = server.flavor.name;
            if ([[server.image logoPrefix] isEqualToString:@"custom"]) {
                cell.imageView.image = [UIImage imageNamed:@"cloud-servers-icon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [server.image logoPrefix]]];
            }
        } else {
            NSInteger index = indexPath.row - [self.loadBalancer.cloudServerNodes count];
            LoadBalancerNode *node = [self.loadBalancer.nodes objectAtIndex:index];
            cell.textLabel.text = node.address;
            cell.detailTextLabel.text = @"";
            cell.imageView.image = nil;
        }
        
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)nextButtonPressed:(id)sender {
    AddLoadBalancerAlgorithmViewController *vc = [[AddLoadBalancerAlgorithmViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodesSection) {
        LBNodesViewController *vc = [[LBNodesViewController alloc] initWithNibName:@"LBNodesViewController" bundle:nil];
        vc.account = self.account;
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];        
    } else if (indexPath.row == kProtocol) {
        LBProtocolViewController *vc = [[LBProtocolViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kVirtualIPType) {
        LBVirtualIPTypeViewController *vc = [[LBVirtualIPTypeViewController alloc] initWithAccount:self.account loadBalancer:self.loadBalancer];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kRegion) {
        AddLoadBalancerRegionViewController *vc = [[AddLoadBalancerRegionViewController alloc] initWithAccount:self.account];
        vc.loadBalancer = self.loadBalancer;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.row == kAlgorithm) {
        LBAlgorithmViewController *vc = [[LBAlgorithmViewController alloc] initWithNibName:@"LBAlgorithmViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

@end
