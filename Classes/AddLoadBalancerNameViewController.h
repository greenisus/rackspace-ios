//
//  AddLoadBalancerNameViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface AddLoadBalancerNameViewController : UITableViewController {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
}

@property (retain) OpenStackAccount *account;
@property (retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
