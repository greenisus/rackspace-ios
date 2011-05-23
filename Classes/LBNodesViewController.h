//
//  LBNodesViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface LBNodesViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    @private
    NSMutableArray *textFields;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

@end
