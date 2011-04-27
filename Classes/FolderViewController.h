//
//  FolderViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/15/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, ActivityIndicatorView, ContainersViewController;

@interface FolderViewController : UITableViewController <UIActionSheetDelegate> {
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;
    
    ContainersViewController *containersViewController;
    FolderViewController *parentFolderViewController;
    NSIndexPath *selectedContainerIndexPath;
    NSIndexPath *selectedFolderIndexPath;
    BOOL contentsLoaded;
    UIActionSheet *deleteActionSheet;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;

@property (retain) ContainersViewController *containersViewController;
@property (retain) NSIndexPath *selectedContainerIndexPath;

@property (retain) FolderViewController *parentFolderViewController;
@property (retain) NSIndexPath *selectedFolderIndexPath;

@property (assign) BOOL contentsLoaded;

@end
