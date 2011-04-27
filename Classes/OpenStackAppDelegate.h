//
//  OpenStackAppDelegate.h
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface OpenStackAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    UINavigationController *masterNavigationController;
    UIBarButtonItem *barButtonItem;
    RootViewController *rootViewController;
    id serviceUnavailableObserver;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) UINavigationController *masterNavigationController;
@property (retain) UIBarButtonItem *barButtonItem;
@property (retain) RootViewController *rootViewController;

@end

