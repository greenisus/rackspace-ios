//
//  ReferrerACLViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, ActivityIndicatorView, ContainerDetailViewController;

@interface ReferrerACLViewController : UITableViewController <UITextFieldDelegate> {
    ContainerDetailViewController *containerDetailViewController;
    OpenStackAccount *account;
    Container *container;
	UITextField *textField;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;
}

@property (nonatomic, retain) ContainerDetailViewController *containerDetailViewController;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Container *container;

-(void)saveButtonPressed:(id)sender;

@end
