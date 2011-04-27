//
//  APILoggingSettingsController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "APILoggingSettingsController.h"
#import "SettingsViewController.h"
#import "APILogger.h"

#define kLoggingLevel 0
#define kEraseLogs 1

#define kAll 0
#define kOnlyErrors 1
#define kNone 2

@implementation APILoggingSettingsController

@synthesize settingsViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"API Logging";
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kLoggingLevel) {
        return 3;
    } else {
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == kLoggingLevel) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loggingLevel = [defaults stringForKey:@"api_logging_level"]; // "all", "none", "errors"
        NSString *cellLevel = @"";

        cell.textLabel.textAlignment = UITextAlignmentLeft;

        if (indexPath.row == kAll) {
            cell.textLabel.text = @"All";
            cellLevel = @"all";
        } else if (indexPath.row == kOnlyErrors) {
            cell.textLabel.text = @"Errors Only";
            cellLevel = @"errors";
        } else {
            cell.textLabel.text = @"None";
            cellLevel = @"none";
        }

        if ([loggingLevel isEqualToString:cellLevel]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.textLabel.text = @"Erase All API Logs";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }

    
    
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)reselectSettingsTableCell {
    [self.settingsViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kLoggingLevel) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (indexPath.row == kAll) {
            [defaults setValue:@"all" forKey:@"api_logging_level"];
        } else if (indexPath.row == kOnlyErrors) {
            [defaults setValue:@"errors" forKey:@"api_logging_level"];
        } else {
            [defaults setValue:@"none" forKey:@"api_logging_level"];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
    } else if (indexPath.section == kEraseLogs) {
        [APILogger eraseAllLogs];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.settingsViewController.tableView reloadData];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reselectSettingsTableCell) userInfo:nil repeats:NO];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [settingsViewController release];
    [super dealloc];
}


@end

