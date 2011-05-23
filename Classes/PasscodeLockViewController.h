//
//  PasscodeLockViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface PasscodeLockViewController : UITableViewController <UIActionSheetDelegate> {
    UISwitch *simplePasscodeSwitch;
    UISwitch *eraseDataSwitch;
    BOOL passcodeLockOn;
    BOOL simplePasscodeOn;
    BOOL eraseDataOn;
    SettingsViewController *settingsViewController;
}

@property (nonatomic, retain) SettingsViewController *settingsViewController;

@end
