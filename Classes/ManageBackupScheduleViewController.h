//
//  ManageBackupScheduleViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerActionViewController.h"

@class OpenStackAccount, Server, ActivityIndicatorView;

@interface ManageBackupScheduleViewController : ServerActionViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UITableView *tableView;
    OpenStackAccount *account;
    Server *server;
    ActivityIndicatorView *activityIndicatorView;
    
    id successObserver;
    id failureObserver;
    
    IBOutlet UIPickerView *picker;
    
    BOOL scheduleLoaded;
    BOOL dailyMode;
}

@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIPickerView *picker;
@property (retain) OpenStackAccount *account;
@property (retain) Server *server;

- (void)saveButtonPressed:(id)sender;

@end
