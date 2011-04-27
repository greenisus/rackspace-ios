//
//  ManageBackupScheduleViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ManageBackupScheduleViewController.h"
#import "Server.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "BackupSchedule.h"
#import "UIViewController+Conveniences.h"
#import "ActivityIndicatorView.h"
#import "ServerViewController.h"

#define kWeekly 0
#define kDaily 1

@implementation ManageBackupScheduleViewController

@synthesize tableView, account, server, picker;

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)scrollToPickerRow {
    if (dailyMode) {
        NSInteger row = 0;
        NSArray *daily = [BackupSchedule dailyOptions];
        for (int i = 0; i < [daily count]; i++) {
            if ([[daily objectAtIndex:i] isEqualToString:self.server.backupSchedule.daily]) {
                row = i;
                break;
            }
        }
        [picker selectRow:row inComponent:0 animated:NO];
    } else {
        NSInteger row = 0;
        NSArray *weekly = [BackupSchedule weeklyOptions];
        for (int i = 0; i < [weekly count]; i++) {
            if ([[weekly objectAtIndex:i] isEqualToString:self.server.backupSchedule.weekly]) {
                row = i;
                break;
            }
        }
        [picker selectRow:row inComponent:0 animated:NO];
    }
}

- (void)selectFirstRow {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:kWeekly inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self scrollToPickerRow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addSubview:picker];
    
    if (!server.backupSchedule) {
        NSString *activityMessage = @"Loading...";
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
        [activityIndicatorView addToView:self.view];
        [self.account.manager getBackupSchedule:self.server];

        successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getBackupScheduleSucceeded" object:server 
                                                                             queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            [activityIndicatorView removeFromSuperviewAndRelease];
            scheduleLoaded = YES;
            [self.picker reloadAllComponents];
            [self.tableView reloadData];
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(selectFirstRow) userInfo:nil repeats:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
        }];

        failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getBackupScheduleFailed" object:server 
                                                                             queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
        }];  
    }
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    self.server.backupSchedule = nil;
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"You can store one Weekly and one Daily backup image for each server.  New servers can be created with the backup images.";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.row == kWeekly) {
        //cell.selected = !dailyMode;
        cell.textLabel.text = @"Weekly";
        if (server.backupSchedule) {
            cell.detailTextLabel.text = [BackupSchedule humanizedWeeklyForString:server.backupSchedule.weekly];
        } else {
            cell.detailTextLabel.text = @"";
        }
    } else if (indexPath.row == kDaily) {
        //cell.selected = dailyMode;
        cell.textLabel.text = @"Daily";
        if (server.backupSchedule) {
            cell.detailTextLabel.text = [BackupSchedule humanizedDailyForString:server.backupSchedule.daily];
        } else {
            cell.detailTextLabel.text = @"";
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dailyMode = indexPath.row == kDaily;
    [picker reloadAllComponents];
    [self scrollToPickerRow];
}

#pragma mark -
#pragma mark Picker View Delegate and Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (!scheduleLoaded) {
        return 0;
    } else if (dailyMode) {
        return 13;
    } else {
        return 8;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (dailyMode) {
        return [BackupSchedule humanizedDailyForString:[[BackupSchedule dailyOptions] objectAtIndex:row]];
    } else {
        return [BackupSchedule humanizedWeeklyForString:[[BackupSchedule weeklyOptions] objectAtIndex:row]];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (dailyMode) {
        self.server.backupSchedule.daily = [[BackupSchedule dailyOptions] objectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kDaily inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        self.server.backupSchedule.weekly = [[BackupSchedule weeklyOptions] objectAtIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kWeekly inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark -
#pragma mark Save Button

- (void)saveButtonPressed:(id)sender {
    [self.serverViewController showToolbarActivityMessage:@"Updating backup schedule..."];
    [self dismissModalViewControllerAnimated:YES];
    [self.serverViewController.tableView deselectRowAtIndexPath:self.actionIndexPath animated:YES];
    [self.account.manager updateBackupSchedule:self.server];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [tableView release];
    [account release];
    [server release];
    [picker release];
    [super dealloc];
}


@end

