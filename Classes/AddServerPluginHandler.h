//
//  AddServerPluginHandler.h
//  OpenStack
//
//  Created by Mike Mayo on 10/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AddServerPlugin.h"


@interface AddServerPluginHandler : NSObject {

}

+ (void)registerPlugin:(id <AddServerPlugin>)plugin;

+ (NSMutableArray *)plugins;

@end
