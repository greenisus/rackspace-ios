//
//  ChefSettingsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ChefSettingsViewController.h"
#import "ChefValidationKeyViewController.h"
#import "UIColor+MoreColors.h"
#import "SettingsViewController.h"

#define kChefBootstrappingEnabled 0
#define kChefEndpointType 1
#define kChefEndpointConfiguration 2
#define kChefValidationKey 3

@implementation ChefSettingsViewController

@synthesize settingsViewController;

#pragma mark -
#pragma mark Switch

- (void)chefBootstrappingSwitchChanged:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    if (chefBootstrappingSwitch.on) {
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationBottom];
        [defaults setValue:@"YES" forKey:@"chef_bootstrapping_on"];
    } else {
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationTop];
        [defaults setValue:@"NO" forKey:@"chef_bootstrapping_on"];
    }
    [defaults synchronize];
    
    [self.settingsViewController.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Chef Bootstrapping";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    chefBootstrappingSwitch = [[UISwitch alloc] init];
    chefBootstrappingSwitch.on = [[defaults stringForKey:@"chef_bootstrapping_on"] isEqualToString:@"YES"];    
    [chefBootstrappingSwitch addTarget:self action:@selector(chefBootstrappingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    chefURLTextField = [[UITextField alloc] initWithFrame:CGRectMake(30.0, 13.0, 186.0, 24.0)];    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        chefURLTextField.frame = CGRectMake(30.0, 13.0, 368.0, 24.0);
    }
    chefURLTextField.delegate = self;
    chefURLTextField.placeholder = @"Ex: http://mynode/chef";
    chefURLTextField.font = [UIFont systemFontOfSize:17.0];
    chefURLTextField.textColor = [UIColor value1DetailTextLabelColor];
    chefURLTextField.backgroundColor = [UIColor clearColor];
    chefURLTextField.textAlignment = UITextAlignmentRight;
    chefURLTextField.returnKeyType = UIReturnKeyDone;
    chefURLTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    chefURLTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    chefURLTextField.text = [defaults valueForKey:@"chef_bootstrapping_chef_server_url"];

    opscodeOrgTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.0, 13.0, 156.0, 24.0)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        opscodeOrgTextField.frame = CGRectMake(60.0, 13.0, 338.0, 24.0);
    }
    opscodeOrgTextField.delegate = self;
    opscodeOrgTextField.placeholder = @"Ex: greenisus";
    opscodeOrgTextField.font = [UIFont systemFontOfSize:17.0];
    opscodeOrgTextField.textColor = [UIColor value1DetailTextLabelColor];
    opscodeOrgTextField.backgroundColor = [UIColor clearColor];
    opscodeOrgTextField.textAlignment = UITextAlignmentRight;
    opscodeOrgTextField.returnKeyType = UIReturnKeyDone;
    opscodeOrgTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    opscodeOrgTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    opscodeOrgTextField.text = [defaults valueForKey:@"chef_bootstrapping_opscode_organization"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return chefBootstrappingSwitch.on ? 4 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kChefBootstrappingEnabled) {
        return 1;
    } else if (section == kChefEndpointType) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kChefEndpointType) {
        return @"How are you using Chef?";
    } else if (section == kChefEndpointConfiguration) {
        //return @"Chef Server URL";
        //return @"Opscode Organization";
        return @"";
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kChefValidationKey) {
        return @"Enter a validator key or choose a .pem file synced from iTunes.";
    } else {
        return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    
    // Configure the cell...
    if (indexPath.section == kChefBootstrappingEnabled) {
        cell.textLabel.text = @"Chef Bootstrapping";
        cell.detailTextLabel.text = @"";
        cell.accessoryView = chefBootstrappingSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == kChefEndpointType) {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"I use the Opscode Platform.";
            if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"opscode"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            cell.textLabel.text = @"I run my own Chef server.";
            if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"chef_server"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == kChefEndpointConfiguration) {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"opscode"]) {
            cell.textLabel.text = @"Organization";
            cell.accessoryView = opscodeOrgTextField;
        } else {
            cell.textLabel.text = @"Chef URL";
            cell.accessoryView = chefURLTextField;
        }
    } else if (indexPath.section == kChefValidationKey) {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = @"Chef Validator Key";
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kChefValidationKey) {
        ChefValidationKeyViewController *vc = [[ChefValidationKeyViewController alloc] initWithNibName:@"ChefValidationKeyViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.section == kChefEndpointType) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *endpointType = [defaults stringForKey:@"chef_bootstrapping_endpoint_type"];
        
        if (indexPath.row == 0 && ![endpointType isEqualToString:@"opscode"]) {
            [defaults setValue:@"opscode" forKey:@"chef_bootstrapping_endpoint_type"];
            [defaults synchronize];        
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:kChefEndpointConfiguration]] withRowAnimation:UITableViewRowAnimationLeft];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        } else if (indexPath.row == 1 && ![endpointType isEqualToString:@"chef_server"]) {
            [defaults setValue:@"chef_server" forKey:@"chef_bootstrapping_endpoint_type"];
            [defaults synchronize];        
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:kChefEndpointConfiguration]] withRowAnimation:UITableViewRowAnimationLeft];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
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
    if ([textField isEqual:opscodeOrgTextField]) {
        [defaults setValue:result forKey:@"chef_bootstrapping_opscode_organization"];
    } else if ([textField isEqual:chefURLTextField]) {
        [defaults setValue:result forKey:@"chef_bootstrapping_chef_server_url"];
    }
    [defaults synchronize];
    return YES;
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
    [settingsViewController release];
    [chefBootstrappingSwitch release];
    [opscodeOrgTextField release];
    [chefURLTextField release];
    [super dealloc];
}


@end

