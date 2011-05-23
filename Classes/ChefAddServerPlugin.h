//
//  ChefAddServerPlugin.h
//  OpenStack
//
//  Created by Mike Mayo on 10/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AddServerPlugin.h"


@interface ChefAddServerPlugin : NSObject <AddServerPlugin, UITextFieldDelegate> {
    UISwitch *chefBootstrappingSwitch;
    UITableView *addServerTableView;
    UITextField *runListTextField;
    BOOL usingOpscodePlatform;
}

@property (nonatomic, retain) UISwitch *chefBootstrappingSwitch;

@end
