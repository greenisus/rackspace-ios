//
//  ChefSettingsPlugin.h
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "SettingsPlugin.h"

@class SettingsViewController;

@interface ChefSettingsPlugin : NSObject <SettingsPlugin> {
    SettingsViewController *settingsViewController;
    UINavigationController *navigationController;
}


@property (retain) SettingsViewController *settingsViewController;
@property (retain) UINavigationController *navigationController;

@end
