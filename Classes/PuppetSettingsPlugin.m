//
//  PuppetSettingsPlugin.m
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PuppetSettingsPlugin.h"
#import "SettingsPluginHandler.h"
#import "Keychain.h"
#import "SettingsViewController.h"
#import "PuppetSettingsViewController.h"


@implementation PuppetSettingsPlugin

@synthesize settingsViewController, navigationController;

+ (void)load {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    PuppetSettingsPlugin *plugin = [[PuppetSettingsPlugin alloc] init];
    
    [SettingsPluginHandler registerPlugin:plugin];
    // this adds the plugin to an NSMutableArray - doing the retain to maintain this object
    
    [plugin release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults stringForKey:@"puppet_bootstrapping_on"]) {
        [defaults setValue:@"NO" forKey:@"puppet_bootstrapping_on"];
    }
    if (![defaults stringForKey:@"puppet_bootstrapping_server_url"]) {
        [defaults setValue:@"" forKey:@"puppet_bootstrapping_server_url"];
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
    return @"Learn more about Puppet at http://puppetlabs.com/puppet.";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PuppetSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"Puppet Bootstrapping";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"puppet_bootstrapping_on"] isEqualToString:@"NO"]) {
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
    PuppetSettingsViewController *vc = [[PuppetSettingsViewController alloc] initWithNibName:@"PuppetSettingsViewController" bundle:nil];
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
