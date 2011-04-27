//
//  AddContainerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class ContainersViewController, OpenStackAccount;

@interface AddContainerViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *nameTextField;
    ContainersViewController *containersViewController;
    OpenStackAccount *account;
}

@property (retain) ContainersViewController *containersViewController;
@property (retain) OpenStackAccount *account;

@end
