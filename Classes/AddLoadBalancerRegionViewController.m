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
#import "AddLoadBalancerViewController.h"
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
            cell.textLabel.text = @"ORD";
            cell.accessoryType = [self.loadBalancer.region isEqualToString:@"ORD"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        case kDFW:
            cell.textLabel.text = @"DFW";
            cell.accessoryType = [self.loadBalancer.region isEqualToString:@"DFW"] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kORD) {
        self.loadBalancer.region = @"ORD";
    } else if (indexPath.row == kDFW) {
        self.loadBalancer.region = @"DFW";
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

@end
