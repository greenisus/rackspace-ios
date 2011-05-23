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

@property (nonatomic, retain) APILogEntry *logEntry;
@property (nonatomic, retain) NSString *requestDescription;
@property (nonatomic, retain) NSString *responseDescription;
@property (nonatomic, retain) NSString *requestMethod;
@property (nonatomic, retain) NSString *url;

- (void)cancelButtonPressed:(id)sender;
- (void)emailLogEntryButtonPressed:(id)sender;

@end
