//
//  PuppetSettingsPlugin.h
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsPlugin.h"


@interface PuppetSettingsPlugin : NSObject <SettingsPlugin> {
    SettingsViewController *settingsViewController;
    UINavigationController *navigationController;
}


@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic, retain) UINavigationController *navigationController;

@end
