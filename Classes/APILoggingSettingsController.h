//
//  APILoggingSettingsController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface APILoggingSettingsController : UITableViewController {
    SettingsViewController *settingsViewController;
}

@property (retain) SettingsViewController *settingsViewController;

@end
