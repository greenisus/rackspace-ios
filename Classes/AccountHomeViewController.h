//
//  AccountHomeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount, RootViewController;

@interface AccountHomeViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    OpenStackAccount *account;
    RootViewController *rootViewController;
    NSIndexPath *rootViewIndexPath;
    NSArray *observers;
    IBOutlet UITableView *tableView;
    
    NSInteger refreshCount;
    
    id authRetryFailedObserver;
    
    NSInteger totalRows;
    NSInteger computeRow;
    NSInteger storageRow;
    NSInteger loadBalancingRow;
    NSInteger rssFeedsRow;
    NSInteger contactRow;
    NSInteger limitsRow;
    NSInteger accountSettingsRow;
    
    IBOutlet UIBarButtonItem *refreshButton;
}

@property (retain) OpenStackAccount *account;
@property (retain) RootViewController *rootViewController;
@property (retain) NSIndexPath *rootViewIndexPath;
@property (retain) IBOutlet UITableView *tableView;

- (void)refreshButtonPressed:(id)sender;

@end
