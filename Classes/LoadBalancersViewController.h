//
//  LoadBalancersViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface LoadBalancersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    OpenStackAccount *account;
    IBOutlet UITableView *tableView;
    IBOutlet UIToolbar *toolbar;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
