//
//  LBProtocolViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBProtocolViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "UIViewController+Conveniences.h"
#import "APICallback.h"
#import "RSTextFieldCell.h"
#import "LoadBalancerProtocol.h"
#import "ActivityIndicatorView.h"

#define kPort 0
#define kProtocols 1

@implementation LBProtocolViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb {
    self = [self initWithNibName:@"LBProtocolViewController" bundle:nil];
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
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
    //[self addDoneButton];
    self.navigationItem.title = @"Protocol";
    
    // default is HTTP on port 80
    if (!self.loadBalancer.protocol) {
        self.loadBalancer.protocol = [[LoadBalancerProtocol alloc] init];
        self.loadBalancer.protocol.name = @"HTTP";
        self.loadBalancer.protocol.port = 80;
    }

    ActivityIndicatorView *activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Loading..."] text:@"Loading..."];

    [activityIndicatorView addToView:self.view];
    
    NSString *endpoint = [account.loadBalancerURLs objectAtIndex:0];
    [[self.account.manager getLoadBalancerProtocols:endpoint] success:^(OpenStackRequest *request) {
        [activityIndicatorView removeFromSuperviewAndRelease];
        [self.tableView reloadData];
    } failure:^(OpenStackRequest *request){
        [activityIndicatorView removeFromSuperviewAndRelease];
        [self alert:@"Could not load Load Balancer protocols." request:request];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kPort:
            return 1;
        case kProtocols:
            return [self.account.lbProtocols count];
        default:
            return 0;
    }
}

- (RSTextFieldCell *)portCell {
    static NSString *CellIdentifier = @"PortCell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Port";
        cell.textField.delegate = self;
        textField = cell.textField;
    }
    cell.textField.text = [NSString stringWithFormat:@"%i", self.loadBalancer.protocol.port];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPort) {
        return [self portCell];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        // Configure the cell...
        LoadBalancerProtocol *p = [self.account.lbProtocols objectAtIndex:indexPath.row];
        cell.textLabel.text = p.name;
        
        if ([p.name isEqualToString:self.loadBalancer.protocol.name]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LoadBalancerProtocol *p = [self.account.lbProtocols objectAtIndex:indexPath.row];
    self.loadBalancer.protocol = p;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.35 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)tf shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.loadBalancer.protocol.port = [[textField.text stringByReplacingCharactersInRange:range withString:string] intValue];
    return YES;
}

#pragma mark - Button Handler

- (void)doneButtonPressed:(id)sender {
    self.loadBalancer.protocol.port = [textField.text intValue];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
