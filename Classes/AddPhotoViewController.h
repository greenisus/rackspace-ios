//
//  AddPhotoViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, ActivityIndicatorView, FolderViewController;

@interface AddPhotoViewController : UITableViewController <UITextFieldDelegate> {

    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    FolderViewController *folderViewController;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;

    UIImage *image;
    NSData *data;
    UISlider *slider;
    UITextField *nameTextField;
    UILabel *formatLabel;    
    NSString *format;
    UILabel *qualityLabel;
    
    ActivityIndicatorView *qualityActivityIndicatorView;
    
    BOOL transitioning;
    BOOL isFromCamera;
    
    NSInteger formatSection;
    NSInteger qualitySection;
}

@property (retain) UIImage *image;
@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;
@property (assign) BOOL isFromCamera;

@end
