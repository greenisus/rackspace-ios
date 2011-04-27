//
//  RenameServerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "RenameServerViewController.h"
#import "RSTextFieldCell.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackRequest.h"
#import "ServerViewController.h"


@implementation RenameServerViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

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
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"The name is a tag for identifying your server. You can change it at any time. When rebuilding your server, this name is used as the hostname.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RenameCell";
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
		textField = cell.textField;
    }    
    cell.textLabel.text = @"Name";
    return cell;
}

#pragma mark -
#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
	if ([textField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a new server name."];
	} else {
        [self.serverViewController renameServer:textField.text];
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
