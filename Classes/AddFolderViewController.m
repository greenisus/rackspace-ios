//
//  AddFolderViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFolderViewController.h"
#import "RSTextFieldCell.h"
#import "ActivityIndicatorView.h"
#import "UIViewController+Conveniences.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "FolderViewController.h"


@implementation AddFolderViewController

@synthesize account, container, folder, folderViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Folder";
    [self addSaveButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [textField becomeFirstResponder];
}

#pragma mark -
#pragma mark Save Button

- (void)saveButtonPressed:(id)sender {    
    if (!saving) {        
        if ([textField.text isEqualToString:@""]) {
            [self alert:@"Folder Name Required" message:@"Please enter a folder name."];
        } else {
            [textField resignFirstResponder];
            NSString *activityMessage = @"Adding folder...";
            
            // figure out how many folders to create
            
            activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
            [activityIndicatorView addToView:self.view];
            
            // actually create the folders
            StorageObject *object = [[StorageObject alloc] init];
            if (folder && folder.name) {
                object.name = object.fullPath = [NSString stringWithFormat:@"%@/%@", [folder fullPath], textField.text];
            } else {
                object.name = object.fullPath = textField.text;
            }
            
            object.data = [NSData data];
            object.contentType = @"application/directory";

            [self.account.manager writeObject:self.container object:object downloadProgressDelegate:nil];
            
            // observe completion and remove activity view and dismiss the modal view controller
            successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectSucceeded" object:object 
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
            {
                Folder *newFolder = [[Folder alloc] init];
                newFolder.name = [[object.name componentsSeparatedByString:@"/"] lastObject];
                newFolder.parent = folder;
                [folder.folders setObject:newFolder forKey:newFolder.name];
                [folderViewController.tableView reloadData];
                [activityIndicatorView removeFromSuperviewAndRelease];
                [self dismissModalViewControllerAnimated:YES];
                
                [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            }];
            
            failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectFailed" object:object 
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
            {
                [activityIndicatorView removeFromSuperviewAndRelease];
                [self alert:@"There was a problem creating this folder." request:[notification.userInfo objectForKey:@"request"]];
                
                [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
            }];
            
        }
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
    return @"If your folder name contains any forward slash characters, multiple folder objects will be created.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FolderNameCell";
    RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
		textField = cell.textField;
        textField.delegate = self;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }    
    cell.textLabel.text = @"Name";
    return cell;
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
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    [super dealloc];
}

@end

