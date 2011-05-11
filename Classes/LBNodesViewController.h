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

@property (retain) OpenStackAccount *account;
@property (retain) LoadBalancer *loadBalancer;

@end
