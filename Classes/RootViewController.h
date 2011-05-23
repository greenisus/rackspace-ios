//
//  RootViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@interface RootViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    IBOutlet UITableView *tableView;

    UIPopoverController *popoverController;
    id detailItem;    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)settingsButtonPressed:(id)sender;

@end
