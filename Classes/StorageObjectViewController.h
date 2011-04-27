//
//  StorageObjectViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/19/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>
#import "ASIHttpRequest.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import "OpenStackViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class OpenStackAccount, Container, Folder, StorageObject, AnimatedProgressView, FolderViewController;

@interface StorageObjectViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, ASIProgressDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    StorageObject *object;
    BOOL performingAction;
    BOOL fileDownloaded;
    AnimatedProgressView *downloadProgressView;
    BOOL fileDownloading;
    UIActionSheet *deleteActionSheet;
    UIActionSheet *cdnURLActionSheet;
    IBOutlet UITableView *tableView;
    id deleteSuccessObserver;
    id deleteFailureObserver;
    FolderViewController *folderViewController;
    
    NSInteger cdnURLSection;
    NSInteger actionsSection;
    NSInteger deleteSection;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) StorageObject *object;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) FolderViewController *folderViewController;

- (void)setProgress:(float)newProgress;

@end
