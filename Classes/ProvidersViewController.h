//
//  ProvidersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class Provider, RootViewController;

@interface ProvidersViewController : UITableViewController {
    RootViewController *rootViewController;
}

@property (nonatomic, retain) RootViewController *rootViewController;

@end
