//
//  AddFileViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, ActivityIndicatorView, FolderViewController;

@interface AddFileViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    UIImagePickerController *imagePicker;

    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    FolderViewController *folderViewController;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;

    BOOL hasPhotoLibrary;
    BOOL hasCamera;
    BOOL canRecordVideo;
    BOOL hasVideoInLibrary;
    BOOL canRecordAudio;
    
    NSInteger sectionOffset;
    
    NSInteger cameraSection;
    NSInteger cameraRow;
    NSInteger libraryRow;
    
    NSInteger audioSection;
    NSInteger audioRow;
    
    NSInteger textFileSection;
    NSInteger textFileRow;
    
    NSInteger iTunesSection;
    NSInteger iTunesRow;
    
    UIPopoverController *popover;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;

@end
