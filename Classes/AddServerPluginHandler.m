//
//  AddServerPluginHandler.m
//  OpenStack
//
//  Created by Mike Mayo on 10/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AddServerPluginHandler.h"


static NSMutableArray *plugins = nil;

@implementation AddServerPluginHandler

+ (void)initialize {
    plugins = [[NSMutableArray alloc] init];
}

+ (NSMutableArray *)plugins {
    return plugins;
}

+ (void)registerPlugin:(id <AddServerPlugin>)plugin {
    [plugins addObject:plugin];
}

@end
