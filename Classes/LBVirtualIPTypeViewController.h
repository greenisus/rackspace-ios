//
//  LBVirtualIPTypeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface LBVirtualIPTypeViewController : UITableViewController {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    @private
    NSDictionary *descriptions;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
