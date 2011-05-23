//
//  RSSFeedsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 12/14/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface RSSFeedsViewController : UITableViewController {
    OpenStackAccount *account;
    BOOL loaded;
    BOOL comingFromAccountHome;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, assign) BOOL comingFromAccountHome;

@end
