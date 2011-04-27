//
//  ErrorAlerter.h
//  OpenStack
//
//  Created by Mike Mayo on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackRequest, LogEntryModalViewController;

@interface ErrorAlerter : NSObject {
    OpenStackRequest *failedRequest;
    LogEntryModalViewController *logEntryModalViewController;
    UIViewController *viewController;
}

- (void)alert:(NSString *)message request:(OpenStackRequest *)request viewController:(UIViewController *)viewController;

@end
