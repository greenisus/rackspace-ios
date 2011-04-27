//
//  ResetServerAdminPasswordViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ResetServerAdminPasswordViewController.h"
#import "ServerViewController.h"
#import "RSTextFieldCell.h"
#import "UIViewController+Conveniences.h"

@implementation ResetServerAdminPasswordViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[textField becomeFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"The root password will be updated and the server will be restarted.  This process will only work if you have a user line for \"root\" in your passwd or shadow file.";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.row == 0) {
		static NSString *CellIdentifier = @"Cell";
		RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.modalPresentationStyle = UIModalPresentationFormSheet;
			textField = cell.textField;
			textField.text = @"";
			textField.secureTextEntry = YES;
            textField.returnKeyType = UIReturnKeyNext;
            textField.delegate = self;
		}
        cell.textLabel.text = @"Password";
		return cell;
	} else {
		static NSString *CellIdentifier = @"ConfirmCell";
		RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.modalPresentationStyle = UIModalPresentationFormSheet;
			confirmTextField = cell.textField;
			confirmTextField.text = @"";
			confirmTextField.secureTextEntry = YES;
            confirmTextField.delegate = self;
		}
        cell.textLabel.text = @"Confirm";
		return cell;
	}
	
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    if ([textField isEqual:aTextField]) {
        [textField resignFirstResponder];
        [confirmTextField becomeFirstResponder];
    } else {
        [self saveButtonPressed:nil];
    }
    return NO;
}

#pragma mark -
#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
	if ([textField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a new password."];
	} else if ([confirmTextField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please confirm your new password."];
	} else if (![textField.text isEqualToString:confirmTextField.text]) {
		[self alert:@"Error" message:@"The password and confirmation do not match."];
	} else {
        [self.serverViewController changeAdminPassword:textField.text];
        [self dismissModalViewControllerAnimated:YES];
        [self.serverViewController.tableView deselectRowAtIndexPath:actionIndexPath animated:YES];        
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}

@end
