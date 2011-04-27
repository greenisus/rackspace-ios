//
//  PuppetSettingsViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PuppetSettingsViewController.h"
#import "UIColor+MoreColors.h"
#import "SettingsViewController.h"

#define kPuppetBootstrappingEnabled 0
#define kPuppetServerURL 1

@implementation PuppetSettingsViewController

@synthesize settingsViewController;

#pragma mark -
#pragma mark Switch

- (void)puppetBootstrappingSwitchChanged:(id)sender {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)];

    if (puppetBootstrappingSwitch.on) {
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationBottom];
        [defaults setValue:@"YES" forKey:@"puppet_bootstrapping_on"];
    } else {
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationTop];
        [defaults setValue:@"NO" forKey:@"puppet_bootstrapping_on"];
    }
    [defaults synchronize];

    [self.settingsViewController.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Puppet Bootstrapping";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    puppetBootstrappingSwitch = [[UISwitch alloc] init];
    puppetBootstrappingSwitch.on = [[defaults stringForKey:@"puppet_bootstrapping_on"] isEqualToString:@"YES"];
    [puppetBootstrappingSwitch addTarget:self action:@selector(puppetBootstrappingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    puppetURLTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0, 13.0, 166.0, 24.0)];    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        puppetURLTextField.frame = CGRectMake(30.0, 13.0, 348.0, 24.0);
    }
    puppetURLTextField.delegate = self;
    puppetURLTextField.placeholder = @"Ex: mypuppet.com";
    puppetURLTextField.font = [UIFont systemFontOfSize:17.0];
    puppetURLTextField.textColor = [UIColor value1DetailTextLabelColor];
    puppetURLTextField.backgroundColor = [UIColor clearColor];
    puppetURLTextField.textAlignment = UITextAlignmentRight;
    puppetURLTextField.returnKeyType = UIReturnKeyDone;
    puppetURLTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    puppetURLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    puppetURLTextField.text = [defaults valueForKey:@"puppet_bootstrapping_server_url"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return puppetBootstrappingSwitch.on ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kPuppetServerURL) {
        return @"This is the host name for your Puppet Master.";
    } else {
        return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Configure the cell...
    if (indexPath.section == kPuppetBootstrappingEnabled) {
        cell.textLabel.text = @"Puppet";
        cell.detailTextLabel.text = @"";
        cell.accessoryView = puppetBootstrappingSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == kPuppetServerURL) {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Puppet URL";
        cell.accessoryView = puppetURLTextField;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark Text Field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:puppetURLTextField]) {
        [defaults setValue:result forKey:@"puppet_bootstrapping_server_url"];
    }
    [defaults synchronize];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [settingsViewController release];
    [puppetBootstrappingSwitch release];
    [puppetURLTextField release];
    [super dealloc];
}


@end

