//
//  ContainersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface ContainersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    OpenStackAccount *account;
    
    id successObserver;
    id failureObserver;
    
    IBOutlet UIBarButtonItem *refreshButton;
    
    id getContainersSucceededObserver;
    id getContainersFailedObserver;
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) OpenStackAccount *account;

- (void)refreshButtonPressed:(id)sender;

@end
