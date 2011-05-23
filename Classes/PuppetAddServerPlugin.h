//
//  PuppetAddServerPlugin.h
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddServerPlugin.h"


@interface PuppetAddServerPlugin : NSObject <AddServerPlugin> {
    UISwitch *puppetBootstrappingSwitch;
    UITableView *addServerTableView;
}

@property (nonatomic, retain) UISwitch *puppetBootstrappingSwitch;

@end
