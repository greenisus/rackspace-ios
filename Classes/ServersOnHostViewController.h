//
//  ServersOnHostViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface ServersOnHostViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    OpenStackAccount *account;
    NSArray *servers;
    NSString *hostID;
}

@property (retain) UITableView *tableView;
@property (retain) OpenStackAccount *account;
@property (retain) NSArray *servers;
@property (retain) NSString *hostID;

@end
