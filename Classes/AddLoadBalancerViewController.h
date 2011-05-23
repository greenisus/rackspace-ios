//
//  AddLoadBalancerNameViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface AddLoadBalancerViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    @private
    NSDictionary *algorithmNames;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account;

@end
