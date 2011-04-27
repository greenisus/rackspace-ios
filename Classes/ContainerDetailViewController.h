//
//  ContainerDetailViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/22/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Container, ActivityIndicatorView, ContainersViewController;

@interface ContainerDetailViewController : UITableViewController <UIActionSheetDelegate> {
    OpenStackAccount *account;
    Container *container;
    UISwitch *cdnEnabledSwitch;
    UISwitch *logRetentionSwitch;
    UISlider *ttlSlider;
    UILabel *ttlLabel;
    UIActionSheet *cdnURLActionSheet;
    UIActionSheet *deleteActionSheet;
    ContainersViewController *containersViewController;
    ActivityIndicatorView *activityIndicatorView;
    id successObserver;
    id failureObserver;
    NSInteger deleteSection;
    NSIndexPath *selectedContainerIndexPath;
    NSUInteger originalTTL;
    
    BOOL transitioning;
}

@property (retain) OpenStackAccount *account;
@property (retain) Container *container;
@property (retain) ContainersViewController *containersViewController;
@property (retain) NSIndexPath *selectedContainerIndexPath;

@end
