//
//  ContactInformationViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class Provider;

@interface ContactInformationViewController : UITableViewController {
    Provider *provider;
    NSURL *selectedURL;
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, retain) Provider *provider;

@end
