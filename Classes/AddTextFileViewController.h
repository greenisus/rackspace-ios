//
//  AddTextFileViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, Folder, FolderViewController;

@interface AddTextFileViewController : UIViewController {
    IBOutlet UITextView *textView;
    OpenStackAccount *account;
    Container *container;
    Folder *folder;
    FolderViewController *folderViewController;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) Folder *folder;
@property (retain) FolderViewController *folderViewController;

@end
