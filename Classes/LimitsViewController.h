//
//  LimitsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount;

@interface LimitsViewController : OpenStackViewController {
    OpenStackAccount *account;
    NSMutableDictionary *timeTimers;
    IBOutlet UITableView *theTableView;
}

@property (nonatomic, retain) OpenStackAccount *account;

@end
