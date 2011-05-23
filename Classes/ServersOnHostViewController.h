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

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) NSArray *servers;
@property (nonatomic, retain) NSString *hostID;

@end
