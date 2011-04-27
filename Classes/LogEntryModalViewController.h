//
//  LogEntryModalViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class APILogEntry;

@interface LogEntryModalViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    APILogEntry *logEntry;
    NSString *requestDescription;
    NSString *responseDescription;
    NSString *requestMethod;
    NSString *url;
}

@property (retain) APILogEntry *logEntry;
@property (retain) NSString *requestDescription;
@property (retain) NSString *responseDescription;
@property (retain) NSString *requestMethod;
@property (retain) NSString *url;

- (void)cancelButtonPressed:(id)sender;
- (void)emailLogEntryButtonPressed:(id)sender;

@end
