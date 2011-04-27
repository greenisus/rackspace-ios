//
//  AddLoadBalancerRegionViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerRegionViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "AddLoadBalancerNameViewController.h"
#import "LoadBalancer.h"

#define kRegion 0
#define kORD 0
#define kDFW 1


@implementation AddLoadBalancerRegionViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerRegionViewController" bundle:nil];
    if (self) {
        self.account = a;
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
    self.navigationItem.title = @"Region";
    [self addCancelButton];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"For optimal performance, choose the location that is closest to the servers you want to load balance.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case kORD:
            cell.textLabel.text = @"Chicago";
            cell.detailTextLabel.text = @"ORD Region";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kDFW:
            cell.textLabel.text = @"Dallas";
            cell.detailTextLabel.text = @"DFW Region";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AddLoadBalancerNameViewController *vc = [[AddLoadBalancerNameViewController alloc] initWithAccount:self.account];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

@end
