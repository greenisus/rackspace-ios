//
//  UserAgentACLViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "UserAgentACLViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "UIViewController+Conveniences.h"
#import "RSTextFieldCell.h"
#import "ActivityIndicatorView.h"
#import "AccountManager.h"
#import "ContainerDetailViewController.h"


@implementation UserAgentACLViewController

@synthesize account, container, containerDetailViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSaveButton];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self addCancelButton];
    }
    self.navigationItem.title = @"User Agent ACL";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.containerDetailViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] animated:YES];
    }
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
    return @"The User Agent ACL is a Perl Compatible Regular Expression that must match the user agent for all content requests.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ReferrerACLCell";
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
		textField = cell.textField;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate = self;
		
        CGRect rect = CGRectInset(cell.contentView.bounds, 23.0, 12);
        rect.size.height += 5; // make slightly taller to not clip the bottom of text
        textField.frame = rect;
    }    
    cell.textLabel.text = @"";
    textField.text = container.useragentACL;
    return cell;
}

#pragma mark -
#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveButtonPressed:nil];
    return NO;
}

#pragma mark -
#pragma mark Save Button

- (void)saveButtonPressed:(id)sender {
    NSString *oldACL = container.useragentACL;
    NSString *activityMessage = @"Saving...";
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
    [activityIndicatorView addToView:self.view];
    container.useragentACL = textField.text;
    [self.account.manager updateCDNContainer:container];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [containerDetailViewController.tableView reloadData];
           [activityIndicatorView removeFromSuperviewAndRelease];
           [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
           [textField resignFirstResponder];
           [self.navigationController popViewControllerAnimated:YES];
       }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerFailed" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [activityIndicatorView removeFromSuperviewAndRelease];
           container.referrerACL = oldACL;
           textField.text = oldACL;
           [self alert:@"There was a problem updating this container." request:[notification.userInfo objectForKey:@"request"]];

           [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
       }];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [containerDetailViewController release];
    [super dealloc];
}

@end
