//
//  AccountDetailsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class Provider, RootViewController, ProvidersViewController, OpenStackAccount, ActivityIndicatorView;

@interface AccountDetailsViewController : UITableViewController <UITextFieldDelegate> {
    Provider *provider;
    UITextField *usernameTextField;
    UITextField *apiKeyTextField;
    UITextField *providerNameTextField;
    UITextField *apiEndpointTextField;
    RootViewController *rootViewController;
    ProvidersViewController *providersViewController;

    BOOL customProvider;
    NSInteger authenticationSection;
    NSInteger providerSection;
    
    BOOL tableShrunk;
    
    OpenStackAccount *account;
    ActivityIndicatorView *activityIndicatorView;
}

@property (retain) Provider *provider;
@property (retain) RootViewController *rootViewController;
@property (retain) ProvidersViewController *providersViewController;

- (void)saveButtonPressed:(id)sender;

@end
