//
//  APILogsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, ActivityIndicatorView;

@interface APILogsViewController : UITableViewController {
    OpenStackAccount *account;
    ActivityIndicatorView *activityIndicatorView;
    BOOL entriesLoaded;
    NSArray *loggerEntries;
}

@property (retain) OpenStackAccount *account;

@end
