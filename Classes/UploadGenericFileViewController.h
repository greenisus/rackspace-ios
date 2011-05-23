//
//  UploadGenericFileViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, FolderViewController, ActivityIndicatorView;

@interface UploadGenericFileViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    FolderViewController *folderViewController;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;
    NSData *data;
    UITextField *nameTextField;
    UILabel *formatLabel;    
    NSString *format;
    NSString *contentType;
    UITextField *contentTypeTextField;
    BOOL contentTypeEditable;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) FolderViewController *folderViewController;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSString *format;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, assign) BOOL contentTypeEditable;

@end
