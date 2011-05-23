//
//  LBProtocolViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface LBProtocolViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    LoadBalancer *loadBalancer;
    @private
    UITextField *textField;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer;

@end
