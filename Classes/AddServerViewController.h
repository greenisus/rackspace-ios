//
//  AddServerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, Image, ServersViewController, OpenStackRequest, LogEntryModalViewController, AccountHomeViewController;

@interface AddServerViewController : UITableViewController <UITextFieldDelegate> {
    OpenStackAccount *account;
    
    UISlider *serverCountSlider;
    UILabel *serverCountLabel;
    UISlider *flavorSlider;
    UILabel *flavorLabel;
    UITextField *nameTextField;
    UILabel *serverNumbersLabel;
    
    NSInteger nodeCount;
    NSInteger flavorIndex;
    Image *selectedImage;
    
    NSArray *plugins;
    
    ServersViewController *serversViewController;
    NSMutableArray *createServerObservers;
    NSInteger successCount;
    NSInteger failureCount;
    
    OpenStackRequest *failedRequest;
    LogEntryModalViewController *logEntryModalViewController;    
    
    NSInteger maxServers;
    
    AccountHomeViewController *accountHomeViewController;
}

@property (retain) OpenStackAccount *account;
@property (retain) Image *selectedImage;
@property (retain) ServersViewController *serversViewController;
@property (retain) AccountHomeViewController *accountHomeViewController;

- (void)saveButtonPressed:(id)sender;
- (void)setNewSelectedImage:(Image *)image;
- (void)alert:(NSString *)message request:(OpenStackRequest *)request;

@end
