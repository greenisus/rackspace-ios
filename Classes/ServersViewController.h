//
//  ServersViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

@class OpenStackAccount, AccountHomeViewController;

@interface ServersViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    OpenStackAccount *account;
    NSMutableDictionary *renameServerSucceededObservers;
    AccountHomeViewController *accountHomeViewController;
    
    id getImageSucceededObserver;
    id getImageFailedObserver;
    
    IBOutlet UIBarButtonItem *refreshButton;

    BOOL loaded;
    BOOL comingFromAccountHome;
    
    BOOL serversLoaded;
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) OpenStackAccount *account;
@property (retain) AccountHomeViewController *accountHomeViewController;
@property (assign) BOOL comingFromAccountHome;

- (void)refreshButtonPressed:(id)sender;

@end
