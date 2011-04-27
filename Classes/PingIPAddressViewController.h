//
//  PingIPAddressViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 4/23/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class ServerViewController;

@interface PingIPAddressViewController : UIViewController {
    IBOutlet UIWebView *webView;
    NSString *ipAddress;
    ServerViewController *serverViewController;
    IBOutlet UINavigationBar *navigationBar;
}

@property (retain) IBOutlet UIWebView *webView;
@property (retain) ServerViewController *serverViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipAddress:(NSString *)anIPAddress;
- (void)cancelButtonPressed:(id)sender;
- (void)refreshButtonPressed:(id)sender;

@end
