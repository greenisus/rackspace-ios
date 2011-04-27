//
//  ErrorAlerter.m
//  OpenStack
//
//  Created by Mike Mayo on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ErrorAlerter.h"
#import "LogEntryModalViewController.h"
#import "OpenStackRequest.h"
#import "UIViewController+Conveniences.h"
#import "APILogEntry.h"


@implementation ErrorAlerter

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // details button
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            logEntryModalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [viewController presentModalViewController:logEntryModalViewController animated:YES];
        [logEntryModalViewController release];
    }
}

- (void)alert:(NSString *)message request:(OpenStackRequest *)request viewController:(UIViewController *)aViewController {
    
    viewController = aViewController;

    NSString *title = @"Error";
    if (request.responseStatusCode == 0) {
        title = @"Connection Error";
        message = @"Please check your connection or API URL and try again.";
    }

    logEntryModalViewController = [[LogEntryModalViewController alloc] initWithNibName:@"LogEntryModalViewController" bundle:nil];
    logEntryModalViewController.logEntry = [[APILogEntry alloc] initWithRequest:request];
    logEntryModalViewController.requestDescription = [logEntryModalViewController.logEntry requestDescription];
    logEntryModalViewController.responseDescription = [logEntryModalViewController.logEntry responseDescription];
    logEntryModalViewController.requestMethod = [logEntryModalViewController.logEntry requestMethod];
    logEntryModalViewController.url = [[logEntryModalViewController.logEntry url] description];
    
    // present an alert with a Details button to show the API log entry
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Details", nil];
    [alert show];
    [alert release];        
}


@end
