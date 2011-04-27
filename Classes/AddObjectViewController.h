//
//  AddObjectViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, ActivityIndicatorView, FolderViewController;

@interface AddObjectViewController : UITableViewController {
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    ActivityIndicatorView *activityIndicatorView;
    FolderViewController *folderViewController;
    id successObserver;
    id failureObserver;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;

@end
