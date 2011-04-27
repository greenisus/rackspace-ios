//
//  SettingsPluginHandler.h
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "SettingsPlugin.h"

@interface SettingsPluginHandler : NSObject {

}

+ (void)registerPlugin:(id <SettingsPlugin>)plugin;

+ (NSMutableArray *)plugins;

@end
