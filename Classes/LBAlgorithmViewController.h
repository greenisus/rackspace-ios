//
//  LBAlgorithmViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadBalancer;

@interface LBAlgorithmViewController : UITableViewController {
    LoadBalancer *loadBalancer;
    @private
    NSDictionary *descriptions;
    NSDictionary *algorithmValues;
}

@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithLoadBalancer:(LoadBalancer *)loadBalancer;

@end
