//
//  PasscodeLockViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "PasscodeLockViewController.h"
#import "Keychain.h"
#import "UIViewController+Conveniences.h"
#import "PasscodeViewController.h"
#import "SettingsViewController.h"


@implementation PasscodeLockViewController

@synthesize settingsViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)simplePasscodeSwitchChanged:(id)sender {
    // no need to authenticate for this one
    simplePasscodeOn = simplePasscodeSwitch.on;
    if (simplePasscodeOn) {
        [Keychain setString:@"YES" forKey:@"passcode_lock_simple_passcode_on"];
    } else {
        [Keychain setString:@"NO" forKey:@"passcode_lock_simple_passcode_on"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        eraseDataOn = YES;
        [Keychain setString:@"YES" forKey:@"passcode_lock_erase_data_on"];
    } else {
        eraseDataOn = NO;
        [Keychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
    }
    [eraseDataSwitch setOn:eraseDataOn animated:YES];
}

- (void)eraseDataSwitchChanged:(id)sender {
    if (eraseDataSwitch.on) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"All data in this app will be erased after 10 failed passcode attempts." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Enable" otherButtonTitles:nil];
        [sheet showInView:self.view];
        [sheet release];
    } else {
        eraseDataOn = NO;
        [Keychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
    }    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Passcode Lock";
    
    simplePasscodeSwitch = [[UISwitch alloc] init];
    [simplePasscodeSwitch addTarget:self action:@selector(simplePasscodeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    eraseDataSwitch = [[UISwitch alloc] init];
    [eraseDataSwitch addTarget:self action:@selector(eraseDataSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    passcodeLockOn = [[Keychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"];
    simplePasscodeOn = [[Keychain getStringForKey:@"passcode_lock_simple_passcode_on"] isEqualToString:@"YES"];
    eraseDataOn = [[Keychain getStringForKey:@"passcode_lock_erase_data_on"] isEqualToString:@"YES"];
    simplePasscodeSwitch.on = simplePasscodeOn;
    eraseDataSwitch.on = eraseDataOn;
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return @"A simple passcode is a 4 digit number.";
    } else if (section == 3) {
        return @"Erase all data in this app after 10 failed passcode attempts.";
    } else {
        return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (passcodeLockOn) {
            cell.textLabel.text = @"Turn Passcode Off";
        } else {
            cell.textLabel.text = @"Turn Passcode On";
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Change Passcode";
        if (passcodeLockOn) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.accessoryView = nil;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"Simple Passcode";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.accessoryView = simplePasscodeSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (passcodeLockOn) {
            cell.textLabel.textColor = [UIColor grayColor];
            simplePasscodeSwitch.enabled = NO;
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
            simplePasscodeSwitch.enabled = YES;
        }
    } else if (indexPath.section == 3) {
        cell.textLabel.text = @"Erase Data";
        cell.textLabel.textAlignment = UITextAlignmentLeft;
        cell.accessoryView = eraseDataSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (passcodeLockOn) {
            cell.textLabel.textColor = [UIColor blackColor];
            eraseDataSwitch.enabled = YES;
        } else {
            cell.textLabel.textColor = [UIColor grayColor];
            eraseDataSwitch.enabled = NO;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if (indexPath.section == 0) {
        PasscodeViewController *vc = [[PasscodeViewController alloc] initWithNibName:@"PasscodeViewController" bundle:nil];
        if (passcodeLockOn) {
            vc.mode = kModeDisablePasscode;
        } else {
            vc.mode = kModeSetPasscode;
        }
        vc.settingsViewController = self.settingsViewController;
        vc.passcodeLockViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [self presentModalViewControllerWithNavigation:vc];
        [vc release];
    } else if (indexPath.section == 1 && passcodeLockOn) {
        PasscodeViewController *vc = [[PasscodeViewController alloc] initWithNibName:@"PasscodeViewController" bundle:nil];
        vc.mode = kModeChangePasscode;
        vc.settingsViewController = self.settingsViewController;
        vc.passcodeLockViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [self presentModalViewControllerWithNavigation:vc];
        [vc release];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [simplePasscodeSwitch release];
    [eraseDataSwitch release];
    [settingsViewController release];
    [super dealloc];
}


@end

