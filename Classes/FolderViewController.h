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

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) Folder *folder;

@property (nonatomic, retain) ContainersViewController *containersViewController;
@property (nonatomic, retain) NSIndexPath *selectedContainerIndexPath;

@property (nonatomic, retain) FolderViewController *parentFolderViewController;
@property (nonatomic, retain) NSIndexPath *selectedFolderIndexPath;

@property (nonatomic, assign) BOOL contentsLoaded;

@end
