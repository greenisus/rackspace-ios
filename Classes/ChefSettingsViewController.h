//
//  ChefSettingsViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface ChefSettingsViewController : UITableViewController <UITextFieldDelegate> {
    SettingsViewController *settingsViewController;
    UISwitch *chefBootstrappingSwitch;
    UITextField *chefURLTextField;
    UITextField *opscodeOrgTextField;
}

@property (nonatomic, retain) SettingsViewController *settingsViewController;

@end
