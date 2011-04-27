//
//  LoadBalancersViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface LoadBalancersViewController : UITableViewController {
    OpenStackAccount *account;
}

@property (retain) OpenStackAccount *account;

@end
