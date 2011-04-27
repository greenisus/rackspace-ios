//
//  AddLoadBalancerNameViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerNameViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"
#import "UIColor+MoreColors.h"
#import "AddLoadBalancerAlgorithmViewController.h"
#import "LoadBalancer.h"

#define kName 0
#define kProtocol 1
#define kVirtualIPType 2
#define kContinue 3

@implementation AddLoadBalancerNameViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerNameViewController" bundle:nil];
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
    self.navigationItem.title = @"Name";
    [self addNextButton];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kProtocol) {
        return @"Nodes will use this protocol and port by default.";
    } else if (section == kVirtualIPType) {
        return @"Virtual IPs are accessible over the Internet.";
    } else {
        return @"";
    }
}

- (UITableViewCell *)nameCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"NameCell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = @"Name";
        cell.textField.placeholder = @"Ex: web-loadbalancer";
    }
    return cell;
}

- (UITableViewCell *)continueCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"ContinueCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor value1DetailTextLabelColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = @"Continue";
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kName) {
        return [self nameCell:tableView];
    } else if (indexPath.section == kContinue) {
        return [self continueCell:tableView];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        switch (indexPath.section) {
            case kProtocol:
                cell.textLabel.text = @"Protocol";
                cell.detailTextLabel.text = @"HTTP on Port 80";
                break;
            case kVirtualIPType:
                cell.textLabel.text = @"Virtual IP Type";
                cell.detailTextLabel.text = @"Shared Virtual IP";
                break;
            default:
                break;
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
    if (indexPath.section == kContinue) {
        [self nextButtonPressed:nil];
    }
}

@end
