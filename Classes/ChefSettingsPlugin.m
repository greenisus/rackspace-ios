//
//  ChefSettingsPlugin.m
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ChefSettingsPlugin.h"
#import "SettingsPluginHandler.h"
#import "Keychain.h"
#import "ChefSettingsViewController.h"
#import "SettingsViewController.h"


@implementation ChefSettingsPlugin

@synthesize settingsViewController, navigationController;

+ (void)load {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    ChefSettingsPlugin *plugin = [[ChefSettingsPlugin alloc] init];

    [SettingsPluginHandler registerPlugin:plugin];
    // this adds the plugin to an NSMutableArray - doing the retain to maintain this object
    
    [plugin release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults stringForKey:@"chef_bootstrapping_on"]) {
        [defaults setValue:@"NO" forKey:@"chef_bootstrapping_on"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_endpoint_type"]) {
        [defaults setValue:@"opscode" forKey:@"chef_bootstrapping_endpoint_type"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_opscode_organization"]) {
        [defaults setValue:@"" forKey:@"chef_bootstrapping_opscode_organization"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_chef_server_url"]) {
        [defaults setValue:@"" forKey:@"chef_bootstrapping_chef_server_url"];
    }
    if (![Keychain getStringForKey:@"chef_bootstrapping_validator_key"]) {
        [Keychain setString:@"" forKey:@"chef_bootstrapping_validator_key"];
    }
    [defaults synchronize];

    [pool release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Learn more about Chef at http://opscode.com/chef.";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChefSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"Chef Bootstrapping";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"chef_bootstrapping_on"] isEqualToString:@"NO"]) {
        cell.detailTextLabel.text = @"Off";
    } else {
        cell.detailTextLabel.text = @"On";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChefSettingsViewController *vc = [[ChefSettingsViewController alloc] initWithNibName:@"ChefSettingsViewController" bundle:nil];
    vc.settingsViewController = self.settingsViewController;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)dealloc {
    [settingsViewController release];
    [navigationController release];
    [super dealloc];
}

@end
