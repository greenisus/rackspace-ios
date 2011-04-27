//
//  SettingsPluginHandler.m
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "SettingsPluginHandler.h"
#import "SettingsPlugin.h"

static NSMutableArray *plugins = nil;

@implementation SettingsPluginHandler

+ (void)initialize {
    plugins = [[NSMutableArray alloc] init];
}

+ (NSMutableArray *)plugins {
    return plugins;
}

+ (void)registerPlugin:(id <SettingsPlugin>)plugin {
    [plugins addObject:plugin];
}

@end
