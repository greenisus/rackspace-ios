//
//  LoadBalancersViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface LoadBalancersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    OpenStackAccount *account;
    IBOutlet UITableView *tableView;
    @private
    BOOL lbsLoaded;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)refreshButtonPressed:(id)sender;

@end
