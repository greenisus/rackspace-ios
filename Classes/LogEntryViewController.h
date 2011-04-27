//
//  LogEntryViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class APILogEntry;

@interface LogEntryViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
    APILogEntry *logEntry;
}

@property (retain) APILogEntry *logEntry;

@end
