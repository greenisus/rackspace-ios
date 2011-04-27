//
//  LimitsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "LimitsViewController.h"
#import "OpenStackAccount.h"
#import "NSObject+Conveniences.h"
#import "RateLimit.h"
#import "UIColor+MoreColors.h"

#define kAbsoluteLimits 0
#define kAPIRateLimits 1

@implementation LimitsViewController

@synthesize account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"API Rate Limits";
    timeTimers = [[NSMutableDictionary alloc] init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *backgroundContainer = [[UIView alloc] init];
        backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        NSString *logoFilename = @"api-rate-limits-icon-large.png";
        UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
        osLogo.contentMode = UIViewContentModeScaleAspectFit;
        osLogo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            osLogo.alpha = 0.3;
        }
        [backgroundContainer addSubview:osLogo];
        [osLogo release];
        theTableView.backgroundView = backgroundContainer;
        [backgroundContainer release];
    } 
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *keys = [timeTimers allKeys];
    for (int i = 0; i < [keys count]; i++) {
        NSIndexPath *key = [keys objectAtIndex:i];
        NSTimer *timer = [timeTimers objectForKey:key];
        [timer invalidate];
        [timeTimers removeObjectForKey:key];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.account.rateLimits count] == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"No API Rate Limits found";
        label.textColor = [UIColor tableViewHeaderColor];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.shadowOffset = CGSizeMake(0, 1.0);
        label.shadowColor = [UIColor whiteColor];
        tableView.backgroundView = label;
        [label release];
    }
    
    return [self.account.sortedRateLimits count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RateLimit *limit = [self.account.sortedRateLimits objectAtIndex:section];
    return [[LimitsViewController timeUntilDate:limit.resetTime] isEqualToString:@""] ? 2 : 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //RateLimit *limit = [self.account.sortedRateLimits objectAtIndex:section];
    return @""; //[NSString stringWithFormat:@"%@ %@", limit.verb, limit.uri];
}

- (void)reloadTimeCell:(NSTimer*)theTimer {
    NSIndexPath *indexPath = [theTimer.userInfo objectForKey:@"indexPath"];
    UITableView *tableView = [theTimer.userInfo objectForKey:@"tableView"];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    }
    
    RateLimit *limit = [self.account.sortedRateLimits objectAtIndex:indexPath.section];

    if (indexPath.row == 0) {
        //cell.textLabel.text = @"Remaining";
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", limit.verb, limit.uri];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i of %i per %@", limit.remaining, limit.value, limit.unit];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i of %i/%@", limit.remaining, limit.value, [limit.unit lowercaseString]];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Regex";
        cell.detailTextLabel.text = limit.regex;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Reset Countdown";
        cell.detailTextLabel.text = [LimitsViewController timeUntilDate:limit.resetTime];
        if (![timeTimers objectForKey:indexPath]) {
            [timeTimers setObject:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadTimeCell:) userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:cell.detailTextLabel.text, indexPath, tableView, nil] forKeys:[NSArray arrayWithObjects:@"string", @"indexPath", @"tableView", nil]] repeats:YES] forKey:indexPath];
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [timeTimers release];
    [super dealloc];
}

@end
