//
//  UploadGenericFileViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadGenericFileViewController.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Container.h"
#import "Folder.h"
#import "FolderViewController.h"
#import "ActivityIndicatorView.h"
#import "UIViewController+Conveniences.h"
#import "UIColor+MoreColors.h"
#import "StorageObject.h"
#import "OCMimeType.h"
#import "RSTextFieldCell.h"

#define kName 0
#define kContentType 1


@implementation UploadGenericFileViewController

@synthesize account, container, folder, folderViewController, data, format, contentType, contentTypeEditable;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add File";
    [self addSaveButton];
}

- (void)viewWillAppear:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(98.0, 13.0, 400.0, 24.0)];
    } else {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, 13.0, 222.0, 24.0)];
    }    
    nameTextField.delegate = self;
    nameTextField.font = [UIFont systemFontOfSize:17.0];
    nameTextField.textColor = [UIColor value1DetailTextLabelColor];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.textAlignment = UITextAlignmentRight;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;    
    nameTextField.placeholder = [NSString stringWithFormat:@"ios_upload_%.0f", [[NSDate date] timeIntervalSince1970]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(41.0, 15.5, 458.0, 18.0)];
    } else {
        formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 15.5, 280.0, 18.0)];
    }    
    formatLabel.font = [UIFont systemFontOfSize:17.0];
    formatLabel.textColor = [UIColor value1DetailTextLabelColor];
    formatLabel.backgroundColor = [UIColor clearColor];
    formatLabel.textAlignment = UITextAlignmentRight;
    if (!self.format) {
        self.format = @"";
    } else if ([self.format isEqualToString:@".mov"]) {
        self.navigationItem.title = @"Add Video";        
    } else if ([self.format isEqualToString:@".txt"]) {
        self.navigationItem.title = @"Add Text File";
    }    

    formatLabel.text = self.format;
    
    // move the text field to make room for the numbers label
    CGSize size = [formatLabel.text sizeWithFont:formatLabel.font constrainedToSize:CGSizeMake(280.0, 900.0f)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nameTextField.frame = CGRectMake(98.0, 13.0, 400.0 - size.width, 24.0);
    } else {
        nameTextField.frame = CGRectMake(79.0, 13.0, 222.0 - size.width, 24.0);
    }    
    
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        contentTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, 13.0, 400.0, 24.0)];
    } else {
        contentTypeTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, 13.0, 222.0, 24.0)];
    }    
    contentTypeTextField.delegate = self;
    contentTypeTextField.font = [UIFont systemFontOfSize:17.0];
    contentTypeTextField.textColor = [UIColor value1DetailTextLabelColor];
    contentTypeTextField.backgroundColor = [UIColor clearColor];
    contentTypeTextField.textAlignment = UITextAlignmentRight;
    contentTypeTextField.returnKeyType = UIReturnKeyDone;
    contentTypeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    contentTypeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (contentTypeEditable) {
        if (self.contentType) {
            contentTypeTextField.text = self.contentType;
        } else {
            contentTypeTextField.text = [OCMimeType mimeTypeForFileExtension:[self.format substringFromIndex:1]];
        }
    } else {
        contentTypeTextField.enabled = NO;
        if (self.contentType) {
            contentTypeTextField.placeholder = self.contentType;
        } else {
            contentTypeTextField.placeholder = [OCMimeType mimeTypeForFileExtension:[self.format substringFromIndex:1]];
        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kName) {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kContentType) {
        return @"The Content Type (MIME Type) is a universal way to describe content regardless of the file extension.";
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView textFieldCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kName) {
        static NSString *CellIdentifier = @"NameCell";    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Name";
            [cell addSubview:nameTextField];
            [cell addSubview:formatLabel];
        }
        return cell;
    } else {
        static NSString *CellIdentifier = @"ContentTypeCell";
        RSTextFieldCell *cell = (RSTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.modalPresentationStyle = UIModalPresentationFormSheet;
            cell.textLabel.text = @"Content Type";
            contentTypeTextField = cell.textField;
            if (contentTypeEditable) {
                if (self.contentType) {
                    contentTypeTextField.text = self.contentType;
                } else {
                    contentTypeTextField.text = [OCMimeType mimeTypeForFileExtension:[self.format substringFromIndex:1]];
                }
            } else {
                contentTypeTextField.enabled = NO;
                if (self.contentType) {
                    contentTypeTextField.placeholder = self.contentType;
                } else {
                    contentTypeTextField.placeholder = [OCMimeType mimeTypeForFileExtension:[self.format substringFromIndex:1]];
                }
            }
            
        }    
        return cell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kName && indexPath.row == 0) {
        return [self tableView:tableView textFieldCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kContentType) {
        return [self tableView:tableView textFieldCellForRowAtIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        cell.textLabel.text = @"Size";
        cell.detailTextLabel.text = [Container humanizedBytes:[data length]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
}

#pragma mark -
#pragma mark Save Button

- (void)saveButtonPressed:(id)sender {
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Uploading..." withProgress:YES] text:@"Uploading..." withProgress:YES];
    [activityIndicatorView addToView:self.view];
    
    StorageObject *object = [[StorageObject alloc] init];
    
    if (nameTextField.text && ![nameTextField.text isEqualToString:@""]) {
        object.name = [NSString stringWithFormat:@"%@%@", nameTextField.text, format];
    } else {
        object.name = [NSString stringWithFormat:@"%@%@", nameTextField.placeholder, format];
    }
    object.fullPath = [NSString stringWithFormat:@"%@/%@", [folder fullPath], object.name];
    object.fullPath = [object.fullPath substringFromIndex:1];
    object.contentType = contentTypeTextField.text;
    
    if (!contentType) {
        object.contentType = @"application/octet-stream";
    }
    
    object.data = data;
    object.bytes = [data length];
    
    [self.account.manager writeObject:self.container object:object downloadProgressDelegate:activityIndicatorView.progressView];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectSucceeded" object:object queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                       {
                           [activityIndicatorView removeFromSuperviewAndRelease];
                           object.data = nil;
                           [folder.objects setObject:object forKey:object.name];
                           [folderViewController.tableView reloadData];
                           [self dismissModalViewControllerAnimated:YES];
                           [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
                       }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectFailed" object:object queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                       {
                           [activityIndicatorView removeFromSuperviewAndRelease];
                           [self alert:@"There was a problem uploading the file." request:[notification.userInfo objectForKey:@"request"]];
                           [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
                       }];
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    [data release];
    [format release];
    [contentType release];
    [super dealloc];
}


@end

