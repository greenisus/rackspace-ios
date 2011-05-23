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

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) FolderViewController *folderViewController;

@end
