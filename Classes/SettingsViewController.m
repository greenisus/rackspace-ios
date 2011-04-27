//
//  SettingsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "SettingsViewController.h"
#import "UIViewController+Conveniences.h"
#import "PasscodeLockViewController.h"
#import "Keychain.h"
#import "APILoggingSettingsController.h"
#import "SettingsPluginHandler.h"
#import "SettingsPlugin.h"
#import "AboutViewController.h"

#define kPasscodeLock 0

#define kAPILogs -1

@implementation SettingsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    
    aboutSection = 1 + [[SettingsPluginHandler plugins] count];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

#pragma mark -
#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section > kPasscodeLock && section < aboutSection) {
        id <SettingsPlugin> plugin = [[SettingsPluginHandler plugins] objectAtIndex:section - 1];
        return [plugin tableView:tableView titleForFooterInSection:section];
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + [[SettingsPluginHandler plugins] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kPasscodeLock) {
        return 1;
    } else if (section == kAPILogs) {
        return 1;
    } else if (section == aboutSection) {
        return 1;
    } else {
        id <SettingsPlugin> plugin = [[SettingsPluginHandler plugins] objectAtIndex:section - 1];
        return [plugin tableView:tableView numberOfRowsInSection:section];
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.section == kPasscodeLock) {
        cell.textLabel.text = @"Passcode Lock";
        if ([[Keychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"]) {
            cell.detailTextLabel.text = @"On";
        } else {
            cell.detailTextLabel.text = @"Off";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == kAPILogs) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loggingLevel = [defaults valueForKey:@"api_logging_level"];
        
        cell.textLabel.text = @"API Logging";
        if ([loggingLevel isEqualToString:@"all"]) {
            cell.detailTextLabel.text = @"All";
        } else if ([loggingLevel isEqualToString:@"errors"]) {
            cell.detailTextLabel.text = @"Only Errors"; 
        } else if ([loggingLevel isEqualToString:@"none"]) {
            cell.detailTextLabel.text = @"None";
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == aboutSection) {
        cell.textLabel.text = @"About This App";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        id <SettingsPlugin> plugin = [[SettingsPluginHandler plugins] objectAtIndex:indexPath.section - 1];
        [plugin setSettingsViewController:self];
        [plugin setNavigationController:self.navigationController];
        return [plugin tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPasscodeLock) {
        PasscodeLockViewController *vc = [[PasscodeLockViewController alloc] initWithNibName:@"PasscodeLockViewController" bundle:nil];
        vc.settingsViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.section == kAPILogs) {
        APILoggingSettingsController *vc = [[APILoggingSettingsController alloc] initWithNibName:@"APILoggingSettingsController" bundle:nil];
        vc.settingsViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.section == aboutSection) {
        AboutViewController *vc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        id <SettingsPlugin> plugin = [[SettingsPluginHandler plugins] objectAtIndex:indexPath.section - 1];
        return [plugin tableView:tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}

@end
