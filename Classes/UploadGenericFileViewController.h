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

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;
@property (retain) NSData *data;
@property (retain) NSString *format;
@property (retain) NSString *contentType;
@property (assign) BOOL contentTypeEditable;

@end
