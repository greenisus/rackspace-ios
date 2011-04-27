//
//  ProvidersViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ProvidersViewController.h"
#import "Provider.h"
#import "AccountDetailsViewController.h"
#import "RootViewController.h"
#import "UIViewController+Conveniences.h"


@implementation ProvidersViewController

@synthesize rootViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Provider";
    [self addCancelButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Please select your provider.";
    } else {
        return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return [[Provider providers] count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == [[Provider providers] count]) {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = @"Other";
        cell.detailTextLabel.text = @"Custom API Configuration";
        cell.imageView.image = [UIImage imageNamed:@"openstack-icon.png"];
    } else {
        Provider *provider = [[Provider providers] objectAtIndex:indexPath.row];
        cell.textLabel.text = provider.name;
        cell.detailTextLabel.text = [provider.authEndpointURL host];
        cell.imageView.image = [UIImage imageNamed:@"rackspacecloud_icon.png"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountDetailsViewController *vc = [[AccountDetailsViewController alloc] initWithNibName:@"AccountDetailsViewController" bundle:nil];
    if (indexPath.row < [[Provider providers] count]) {
        vc.provider = [[Provider providers] objectAtIndex:indexPath.row];
    }
    vc.rootViewController = rootViewController;
    vc.providersViewController = self;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [rootViewController release];
    [super dealloc];
}

@end
