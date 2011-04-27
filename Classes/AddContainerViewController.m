//
//  AddContainerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AddContainerViewController.h"
#import "UIViewController+Conveniences.h"
#import "ContainersViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "AccountManager.h"
#import "RSTextFieldCell.h"


@implementation AddContainerViewController

@synthesize containersViewController, account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Container";
    [self addCancelButton];
    [self addSaveButton];
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
    return @"A container is a storage compartment for your files and provides a way for you to organize your data.  Containers are similar to folders, but cannot be nested.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
        nameTextField = cell.textField;
        nameTextField.delegate = self;
        [nameTextField becomeFirstResponder];
    }
    
    cell.textLabel.text = @"Name";
    
    return cell;
}

#pragma mark -
#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
    if ([nameTextField.text isEqualToString:@""]) {
        [self alert:nil message:@"Please enter a name."];
        [nameTextField becomeFirstResponder];
    } else {
        [self.containersViewController showToolbarActivityMessage:@"Creating container..."];

        Container *container = [[Container alloc] init];
        container.name = nameTextField.text;
        [self.account.manager createContainer:container];
        [container release];
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveButtonPressed:nil];
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [containersViewController release];
    [account release];
    [super dealloc];
}

@end
