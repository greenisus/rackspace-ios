//
//  AddFolderViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, ActivityIndicatorView, FolderViewController;

@interface AddFolderViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *textField;
    ActivityIndicatorView *activityIndicatorView;
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    FolderViewController *folderViewController;
    BOOL saving;
    id successObserver;
    id failureObserver;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;

@end
