//
//  PasscodeViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

#define kModeEnterPasscode 0
#define kModeSetPasscode 1
#define kModeDisablePasscode 2
#define kModeChangePasscode 3

@class PasscodeLockViewController, SettingsViewController, RootViewController, AccountHomeViewController;

// this class asks for the passcode and allows you to set it

@interface PasscodeViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {

    PasscodeLockViewController *passcodeLockViewController;
    SettingsViewController *settingsViewController;
    RootViewController *rootViewController;
    AccountHomeViewController *accountHomeViewController;
    
    UILabel *passcodeConfirmationWarningLabel;
    UIView *failedAttemptsView;
    UILabel *failedAttemptsLabel;
    NSInteger failedAttemptsCount;

    // to be like Apple's passcode lock style, we're going to use three table views
    // and slide them around as needed
    NSUInteger tableIndex;
    NSMutableArray *tableViews;
    NSMutableArray *textFields;
    NSMutableArray *squares;
    
    IBOutlet UITableView *enterPasscodeTableView;
    UITextField *enterPasscodeTextField;
    NSArray *enterPasscodeSquareImageViews;

    IBOutlet UITableView *setPasscodeTableView;
    UITextField *setPasscodeTextField;
    NSArray *setPasscodeSquareImageViews;

    IBOutlet UITableView *confirmPasscodeTableView;
    UITextField *confirmPasscodeTextField;
    NSArray *confirmPasscodeSquareImageViews;

    // there are two modes: entering a password and setting a password
    NSUInteger mode;
    
    BOOL simplePasscodeOn;
    BOOL passcodeLockOn;
    BOOL eraseData;
    
    CGFloat viewWidth;
}

@property (nonatomic, assign) NSUInteger mode;
@property (nonatomic, retain) PasscodeLockViewController *passcodeLockViewController;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) AccountHomeViewController *accountHomeViewController;



@end
