//
//  PuppetSettingsViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface PuppetSettingsViewController : UITableViewController <UITextFieldDelegate> {
    SettingsViewController *settingsViewController;
    UISwitch *puppetBootstrappingSwitch;
    UITextField *puppetURLTextField;
}

@property (nonatomic, retain) SettingsViewController *settingsViewController;

@end
