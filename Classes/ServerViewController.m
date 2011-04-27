//
//  ServerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServerViewController.h"
#import "Server.h"
#import "OpenStackAccount.h"
#import "Image.h"
#import "Flavor.h"
#import "UIViewController+Conveniences.h"
#import "PingIPAddressViewController.h"
#import "RenameServerViewController.h"
#import "ResetServerAdminPasswordViewController.h"
#import "AccountManager.h"
#import "NSObject+Conveniences.h"
#import "ServersViewController.h"
#import "ResizeServerViewController.h"
#import "RebuildServerViewController.h"
#import "AnimatedProgressView.h"
#import "OpenStackRequest.h"
#import "RateLimit.h"
#import "ManageBackupScheduleViewController.h"
#import "SimpleImagePickerViewController.h"
#import "UIColor+MoreColors.h"
#import <QuartzCore/QuartzCore.h>
#import "AccountHomeViewController.h"
#import "ServersOnHostViewController.h"
#import "NameAndStatusTitleView.h"
#import "APICallback.h"
#import "Provider.h"

// TODO: bring back host id section as "n servers on this (physical) host"

@implementation ServerViewController

@synthesize server, account, tableView, selectedIPAddressIndexPath, serversViewController, selectedServerIndexPath, accountHomeViewController;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //CGPoint point = scrollView.contentOffset;
    //CGRect tr = titleView.frame;
    //CGRect ar = actionView.frame;
    /*
    if (previousScrollPoint.y - point.y < 0) {
        titleView.frame = CGRectMake(tr.origin.x, (previousScrollPoint.y - point.y) / 3.0, tr.size.width, tr.size.height);
        actionView.frame = CGRectMake(ar.origin.x, 64 + ((previousScrollPoint.y - point.y) / 2.0), ar.size.width, ar.size.height);
    }
    */
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect tr = titleView.frame;
        CGRect ar = actionView.frame;
        
        if (self.tableView.contentOffset.y >= 150) {
            tr.origin.y = -67;
            ar.origin.y = -136.0;
        } else {
            tr.origin.y = 0;
            ar.origin.y = 64;
        }
        titleView.frame = tr;
        actionView.frame = ar;
    } completion:^(BOOL finished) {
    }];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setParallaxViews {
    
    if (!titleView) {    
        // make an offset for the table
        self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 134.0)] autorelease];

        titleView = [[NameAndStatusTitleView alloc] initWithEntity:self.server logoFilename:[[self.server.image logoPrefix] stringByAppendingString:@"-icon.png"]];
        [self.view addSubview:titleView];
        [titleView setNeedsDisplay];
    }
    
    actionView.backgroundColor = [UIColor colorWithRed:0.929 green:0.929 blue:0.929 alpha:1];
    actionView.clipsToBounds = NO;
    [actionView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [actionView.layer setShadowRadius:2.0f];
    [actionView.layer setShadowOffset:CGSizeMake(1, 1)];
    [actionView.layer setShadowOpacity:0.8f];
    
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // line up the action buttons with the table view on iPad
        CGRect rebootFrame = rebootButton.frame;
        rebootFrame.origin.x += 14;
        rebootButton.frame = rebootFrame;
    }
     */
    
    
    [self scrollViewDidScroll:self.tableView];
}

- (void)setBackgroundView {
    if (self.server) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIView *backgroundContainer = [[UIView alloc] init];
            backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
            
            NSString *logoFilename = [[self.server.image logoPrefix] stringByAppendingString:@"-large.png"];
            UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
            osLogo.contentMode = UIViewContentModeScaleAspectFit;
            osLogo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                osLogo.alpha = 0.3;        
            }
            
            [backgroundContainer addSubview:osLogo];
            [osLogo release];
            
            tableView.backgroundView = backgroundContainer;
            [backgroundContainer release];
            
        } else {        
            NSString *logoFilename = [[server.image logoPrefix] stringByAppendingString:@"-large.png"];    
            UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
            osLogo.contentMode = UIViewContentModeScaleAspectFit;
            osLogo.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
            tableView.backgroundView = osLogo;
            [osLogo release];
        }
    } else {
        UIView *container = [[UIView alloc] init];
        container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        container.backgroundColor = [UIColor iPadTableBackgroundColor];

        UILabel *label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor emptyCollectionGrayColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        label.text = @"No server selected";
        label.textAlignment = UITextAlignmentCenter;
        [container addSubview:label];
        [label release];
        
        tableView.backgroundView = container;
        [container release];
    }
}

- (void)refreshCountdownLabels:(NSTimer *)timer {
    [self refreshLimitStrings]; 
    
    if (actionsExpanded) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        if (![rebootCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kReboot inSection:kActions]];
        }
        if (![renameCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kRename inSection:kActions]];
        }
        if (![resizeCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kResize inSection:kActions]];
        }
        if (![changePasswordCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kChangePassword inSection:kActions]];
        }
        if (![backupsCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kBackups inSection:kActions]];
        }
        if (![rebuildCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kRebuild inSection:kActions]];
        }
        if (![deleteCountdown isEqualToString:@""]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:kDelete inSection:kActions]];
        }

        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [indexPaths release];        
    }

}

- (void)refreshLimitStrings {

    RateLimit *rebootLimit = [OpenStackRequest softRebootServerLimit:self.account server:self.server];
    if (rebootLimit && rebootLimit.remaining == 0) {
        rebootCountdown = [ServerViewController timeUntilDate:rebootLimit.resetTime];
    }    
    
    RateLimit *renameLimit = [OpenStackRequest renameServerLimit:self.account server:self.server];
    if (renameLimit && renameLimit.remaining == 0) {
        renameCountdown = [ServerViewController timeUntilDate:renameLimit.resetTime];
    }

    RateLimit *resizeLimit = [OpenStackRequest resizeServerLimit:self.account server:self.server];
    if (resizeLimit && resizeLimit.remaining == 0) {
        resizeCountdown = [ServerViewController timeUntilDate:resizeLimit.resetTime];
    }
    
    RateLimit *changePasswordLimit = [OpenStackRequest changeServerAdminPasswordLimit:self.account server:self.server];
    if (changePasswordLimit && changePasswordLimit.remaining == 0) {
        changePasswordCountdown = [ServerViewController timeUntilDate:changePasswordLimit.resetTime];
    }

    RateLimit *backupsLimit = [OpenStackRequest updateBackupScheduleLimit:self.account server:self.server];
    if (backupsLimit && backupsLimit.remaining == 0) {
        backupsCountdown = [ServerViewController timeUntilDate:backupsLimit.resetTime];
    }

    RateLimit *rebuildLimit = nil; // [OpenStackRequest rebuildServerLimit:self.account server:self.server];
    if (rebuildLimit && rebuildLimit.remaining == 0) {
        rebuildCountdown = [ServerViewController timeUntilDate:rebuildLimit.resetTime];
    }

    RateLimit *deleteLimit = [OpenStackRequest deleteServerLimit:self.account server:self.server];
    if (deleteLimit && deleteLimit.remaining == 0) {
        deleteCountdown = [ServerViewController timeUntilDate:deleteLimit.resetTime];
    }
}

- (void)pollServer {
    pollRequest = [OpenStackRequest getServerRequest:self.account serverId:self.server.identifier];
    polling = YES;
    pollRequest.delegate = self;
    pollRequest.didFinishSelector = @selector(getServerSucceeded:);
    pollRequest.didFailSelector = @selector(getServerFailed:);
    [pollRequest startAsynchronous];
    [titleView setNeedsDisplay];
}

- (void)getServerSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        self.server = [request server];
        
        self.server.flavor = [self.account.flavors objectForKey:[NSNumber numberWithInt:self.server.flavorId]];
        self.server.image = [self.account.images objectForKey:[NSNumber numberWithInt:self.server.imageId]];
        
        [self.account.servers setObject:server forKey:[NSNumber numberWithInt:self.server.identifier]];
        self.account.sortedServers = nil;        
        [self.account persist];
        
        NSLog(@"polling server worked. %i, %@", self.server.progress, self.server.status);
        [progressView setProgress:self.server.progress animated:YES];
        
        if ([self.server.status isEqualToString:@"VERIFY_RESIZE"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resize Complete" message:@"Confirming the resize will destroy the saved copy of your original server." delegate:self cancelButtonTitle:@"Decide Later" otherButtonTitles:@"Confirm Resize", @"Revert to Previous Size", nil];
            [alert show];
            [alert release];
        }
    }
    if (kOverview >= 0) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kStatus inSection:kOverview]] withRowAnimation:UITableViewRowAnimationNone];
    }
    if ([self.server shouldBePolled]) {
        [self pollServer];
    } else {
        polling = NO;        
        //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kStatus inSection:kOverview]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadData];
        [self setBackgroundView];
        titleView.logoView.image = [UIImage imageNamed:[[self.server.image logoPrefix] stringByAppendingString:@"-icon.png"]];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [self.serversViewController.tableView reloadData];
        }
        
    }
    titleView.entity = self.server;
    [titleView setNeedsDisplay];
    
}

- (void)getServerFailed:(OpenStackRequest *)request {
    NSLog(@"polling server failed. trying again.");
    [self pollServer];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    actionsExpanded = YES;

    previousScrollPoint = CGPointZero;
    titleView = nil;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"ssh://123.123.123.123"];
    if ([application canOpenURL:url]) {
        ipAddressActionSheet = [[UIActionSheet alloc] initWithTitle:selectedIPAddress delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Ping IP Address", @"Copy to Pasteboard", @"Open in Safari", @"Open in SSH Client", nil];
    } else {
        ipAddressActionSheet = [[UIActionSheet alloc] initWithTitle:selectedIPAddress delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Ping IP Address", @"Copy to Pasteboard", @"Open in Safari", nil];    
    }
    
    rebootActionSheet = [[UIActionSheet alloc] initWithTitle:@"A soft reboot performs a graceful shutdown of your system.  A hard reboot is the equivalent of unplugging your server." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Perform Hard Reboot" otherButtonTitles:@"Perform Soft Reboot", nil];
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this server?  This operation cannot be undone and you will lose all backup images." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Server" otherButtonTitles:nil];    
    progressView = [[AnimatedProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = progressView.frame;
        rect.size.width = 440.0;
        progressView.frame = rect;
    }
    
    actionsArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-up.png"]];
    actionsArrow.highlightedImage = [UIImage imageNamed:@"arrow-up-highlighted.png"];
    actionsArrow.transform = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    self.navigationItem.title = [self.account.provider isRackspace] ? @"Cloud Server" : @"Server";
    [self setBackgroundView];
    
    if (self.server) {
        [self setParallaxViews];
    } else {
        actionView.alpha = 0;
        rebootButton.enabled = NO;
        pingButton.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    rebootCountdown = @"";
    renameCountdown = @"";
    resizeCountdown = @"";
    changePasswordCountdown = @"";
    backupsCountdown = @"";
    rebuildCountdown = @"";
    deleteCountdown = @"";
    
    [self refreshLimitStrings];
    
    // handle success
    if (!getLimitsSucceededObserver) {
        getLimitsSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getLimitsSucceeded" object:self.account
                                                                                        queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            OpenStackRequest *request = [notification.userInfo objectForKey:@"request"];
            self.account.rateLimits = [request rateLimits];
            [[NSNotificationCenter defaultCenter] removeObserver:getLimitsSucceededObserver];
        }];
        
        getImageSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getImageSucceeded" object:nil
                                                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            Image *image = [self.account.images objectForKey:[NSNumber numberWithInt:self.server.imageId]];
            self.server.image = image;

            NSString *logoFilename = [[server.image logoPrefix] stringByAppendingString:@"-large.png"];    
            UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
            osLogo.contentMode = UIViewContentModeScaleAspectFit;
            osLogo.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
            tableView.backgroundView = osLogo;
            [osLogo release];

            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kImage inSection:kDetails]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        getImageFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getImageFailed" object:[NSNumber numberWithInt:self.server.imageId]
                                                                                    queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            NSLog(@"loading image failed");
        }];
        
        updateBackupScheduleSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateBackupScheduleSucceeded" object:self.server
                                                                                                   queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
        }];
        
        updateBackupScheduleFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateBackupScheduleFailed" object:self.account
                                                                                                queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem updating your backup schedule." request:[notification.userInfo objectForKey:@"request"]];
        }];    
        
        resizeServerSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"resizeServerSucceeded" identifier:self.server.identifier] object:nil
                                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            self.server.status = @"QUEUE_RESIZE";
            if (kOverview >= 0) {
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:kStatus inSection:kOverview]] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self pollServer];        
        }];
        
        resizeServerFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"resizeServerFailed" identifier:self.server.identifier] object:nil
                                                                                        queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem resizing this server." request:[notification.userInfo objectForKey:@"request"]];
        }];
        
        confirmResizeSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"confirmResizeServerSucceeded" identifier:self.server.identifier] object:nil
                                                                                            queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self pollServer];        
        }];
        
        confirmResizeFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"confirmResizeServerFailed" identifier:self.server.identifier] object:nil
                                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem confirming the resize." request:[notification.userInfo objectForKey:@"request"]];
        }];
        
        revertResizeSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"revertResizeServerSucceeded" identifier:self.server.identifier] object:nil
                                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self pollServer];        
        }];
        
        revertResizeFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"revertResizeServerFailed" identifier:self.server.identifier] object:nil
                                                                                        queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem reverting the resize." request:[notification.userInfo objectForKey:@"request"]];
        }];
        
        rebuildSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"rebuildServerSucceeded" identifier:self.server.identifier] object:nil
                                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self pollServer];        
        }];
        
        rebuildFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[self.account.manager notificationName:@"rebuildServerFailed" identifier:self.server.identifier] object:nil
                                                                                   queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            [self alert:@"There was a problem rebuilding this server." request:[notification.userInfo objectForKey:@"request"]];
        }];
    }
    
    // if the server has less than 100% progress, we need to poll it.
    // normally, we would do this through the account manager, but this is the only
    // place we'll need the information.  the downside to this is that we may
    // temporarily show a server as building when it's already complete, but that's
    // better than the possibility of polling several servers at once when a user
    // decides to add multiple nodes
    if (self.server && [server shouldBePolled]) {
        [self pollServer];
    }
    
    if (!countdownTimer) {        
        countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshCountdownLabels:) userInfo:nil repeats:YES];
    }    
    
    if (self.server && [self.server.status isEqualToString:@"VERIFY_RESIZE"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resize Complete" message:@"Confirming the resize will destroy the saved copy of your original server." delegate:self cancelButtonTitle:@"Decide Later" otherButtonTitles:@"Confirm Resize", @"Revert to Previous Size", nil];
        [alert show];
        [alert release];
    }    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:rebootSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:rebootFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:getLimitsSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:deleteServerSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:deleteServerFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:getImageSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:getImageFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:updateBackupScheduleSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:updateBackupScheduleFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:resizeServerSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:resizeServerFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:confirmResizeSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:confirmResizeFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:revertResizeSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:revertResizeFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:rebuildSucceededObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:rebuildFailedObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (polling && pollRequest != nil) {
        pollRequest.delegate = nil;
    }
    
    [self.serversViewController.tableView deselectRowAtIndexPath:self.selectedServerIndexPath animated:YES];
    
    [countdownTimer invalidate];
    countdownTimer = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return self.server ? 5 : 0;
    return self.server ? 4 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kOverview) {
        if (self.account.serversByHost && [self.account.serversByHost count] > 0) {
            NSArray *serversOnHost = [self.account.serversByHost objectForKey:self.server.hostId];
            if (serversOnHost && [serversOnHost count] > 1) {
                return 3;
            } else {
                return 2;
            }
        } else {
            return 2;
        }
    } else if (section == kDetails) {
        return 2;
    } else if (section == kIPAddresses) {
        NSArray *publicIPs = [server.addresses objectForKey:@"public"];
        NSArray *privateIPs = [server.addresses objectForKey:@"private"];
        return [publicIPs count] + [privateIPs count];
    } else if (section == kActions) {
        //return actionsExpanded ? 8 : 1;
        return 6;
    } else {
        return 0;
    }
}

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textLabelSize = CGSizeMake(530.0, 9000.0f);
    } else {
        textLabelSize = CGSizeMake(230.0, 9000.0f);
    }
    
    // pad \n\n to fix layout bug
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
    return stringSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.93];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;

    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryView = nil;

    if (indexPath.section == kOverview) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;

        if (indexPath.row == kName) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = server.name;
        } else if (indexPath.row == kStatus) {
            if ([server.status isEqualToString:@"BUILD"]) {
                cell.textLabel.text = @"Building";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = progressView;
            } else if ([server.status isEqualToString:@"QUEUE_RESIZE"]) {
                cell.textLabel.text = @"Queueing";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = progressView;
            } else if ([server.status isEqualToString:@"PREP_RESIZE"]) {
                cell.textLabel.text = @"Preparing";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = progressView;
            } else if ([server.status isEqualToString:@"RESIZE"]) {
                cell.textLabel.text = @"Resizing";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = progressView;
            } else if ([server.status isEqualToString:@"VERIFY_RESIZE"]) {
                cell.textLabel.text = @"Status";
                cell.detailTextLabel.text = @"Resize Complete";
            } else if ([server.status isEqualToString:@"REBUILD"]) {
                cell.textLabel.text = @"Rebuilding";
                cell.detailTextLabel.text = @"";
                cell.accessoryView = progressView;
            } else {
                cell.textLabel.text = @"Status";
                cell.detailTextLabel.text = server.status;
            }
            
        } else if (indexPath.row == kHostId) {
            cell.textLabel.text = @"Host ID";
            cell.detailTextLabel.text = server.hostId;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    } else if (indexPath.section == kDetails) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;

        if (indexPath.row == kImage) {
            cell.textLabel.text = @"Image";
            //cell.textLabel.text = server.image.name;
            cell.detailTextLabel.text = server.image.name; 
        } else if (indexPath.row == kMemory) {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i MB RAM, %i GB Disk", self.server.flavor.ram, self.server.flavor.disk];
            //cell.textLabel.text = @"Memory";
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"%i MB", server.flavor.ram];
        } else if (indexPath.row == kDisk) {
            cell.textLabel.text = @"Disk";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i GB", server.flavor.disk];
        }
    } else if (indexPath.section == kIPAddresses) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
        
        NSArray *publicIPs = [server.addresses objectForKey:@"public"];
        NSArray *privateIPs = [server.addresses objectForKey:@"private"];
        
        if (indexPath.row < [publicIPs count]) {
            cell.textLabel.text = @"Public";
            cell.detailTextLabel.text = [publicIPs objectAtIndex:indexPath.row];
            if ([[publicIPs objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
                // v1.0 API
                cell.detailTextLabel.text = [publicIPs objectAtIndex:indexPath.row];
            } else {
                // v1.1 API
                cell.detailTextLabel.text = [[publicIPs objectAtIndex:indexPath.row] objectForKey:@"addr"];
            }            
        } else {
            cell.textLabel.text = @"Private";
            if ([[privateIPs objectAtIndex:[publicIPs count] - indexPath.row] isKindOfClass:[NSString class]]) {
                // v1.0 API
                cell.detailTextLabel.text = [privateIPs objectAtIndex:[publicIPs count] - indexPath.row];
            } else {
                // v1.1 API
                cell.detailTextLabel.text = [[privateIPs objectAtIndex:[publicIPs count] - indexPath.row] objectForKey:@"addr"];
            }            
        }
    } else if (indexPath.section == kActions) {
        cell.textLabel.text = @"Actions";
        cell.detailTextLabel.text = @"";
        cell.accessoryView = nil;
        if (indexPath.row == kActionsRow) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = actionsArrow;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.textColor = actionsExpanded ? cell.detailTextLabel.textColor : [UIColor blackColor];
        } else {
            if (performingAction) {
                cell.textLabel.textColor = [UIColor grayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            
            if (indexPath.row == kReboot) {
                cell.textLabel.text = @"Reboot Server";
                if (![rebootCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = rebootCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kRename) {
                cell.textLabel.text = @"Rename Server";
                if (renameCountdown && ![renameCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = renameCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kResize) {
                cell.textLabel.text = @"Resize Server";
                if (![resizeCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = resizeCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kChangePassword) {
                cell.textLabel.text = @"Change Root Password";
                if (![changePasswordCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = changePasswordCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kBackups) {
                cell.textLabel.text = @"Manage Backup Schedules";
                if (![backupsCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = backupsCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kRebuild) {
                cell.textLabel.text = @"Rebuild Server";
                if (![rebuildCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = rebuildCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            } else if (indexPath.row == kDelete) {
                cell.textLabel.text = @"Delete Server";
                if (![deleteCountdown isEqualToString:@""]) {
                    cell.detailTextLabel.text = deleteCountdown;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                } else {
                    cell.detailTextLabel.text = @"";
                }
            }
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)reloadActionsTitleRow {
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:kActions]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == kOverview) {
        if (indexPath.row == kHostId) {
            ServersOnHostViewController *vc = [[ServersOnHostViewController alloc] initWithNibName:@"ServersOnHostViewController" bundle:nil];
            vc.account = self.account;
            vc.servers = [self.account.serversByHost objectForKey:self.server.hostId];
            vc.hostID = self.server.hostId;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            
            // deselect the row
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        }
    } else if (indexPath.section == kIPAddresses) {
        NSArray *publicIPs = [server.addresses objectForKey:@"public"];
        NSArray *privateIPs = [server.addresses objectForKey:@"private"];
        if (indexPath.row < [publicIPs count]) {
            if ([[publicIPs objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
                selectedIPAddress = [publicIPs objectAtIndex:indexPath.row];
            } else {
                selectedIPAddress = [[publicIPs objectAtIndex:indexPath.row] objectForKey:@"addr"];
            }
        } else {
            if ([[privateIPs objectAtIndex:[publicIPs count] - indexPath.row] isKindOfClass:[NSString class]]) {
                selectedIPAddress = [privateIPs objectAtIndex:[publicIPs count] - indexPath.row];
            } else {
                selectedIPAddress = [[privateIPs objectAtIndex:[publicIPs count] - indexPath.row] objectForKey:@"addr"];
            }
        }
        selectedIPAddressIndexPath = indexPath;

        ipAddressActionSheet.title = selectedIPAddress;
        [ipAddressActionSheet showInView:self.view];
    } else if (indexPath.section == kActions) {
        if (indexPath.row == kActionsRow) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:7];
            for (int i = 1; i < 8; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:kActions]];
            }
            if (actionsExpanded) {
                actionsExpanded = NO;
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            } else {
                actionsExpanded = YES;
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            [indexPaths release];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(reloadActionsTitleRow) userInfo:nil repeats:NO];
            
            // flip the arrow
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.4];
            if (actionsExpanded) {
                actionsArrow.transform = CGAffineTransformMakeRotation(0.0);
            } else {
                actionsArrow.transform = CGAffineTransformMakeRotation(180.0 * M_PI / 180.0);
            }
            [UIView commitAnimations];            
            
        } else if (indexPath.row == kReboot) {
            if (!performingAction && [rebootCountdown isEqualToString:@""]) {
                [rebootActionSheet showInView:self.view];
            } else if (![rebootCountdown isEqualToString:@""]) {
                [self alert:nil message:@"Reboots are not available because the API rate limit has been reached for this account.  These actions will be available as soon as the countdown reaches zero."];
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else if (indexPath.row == kRename) {
            if (!performingAction) {
                RenameServerViewController *vc = [[RenameServerViewController alloc] initWithNibName:@"RenameServerViewController" bundle:nil];
                vc.serverViewController = self;
                vc.actionIndexPath = indexPath;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    vc.modalPresentationStyle = UIModalPresentationFormSheet;
                }                
                [self.navigationController presentModalViewController:vc animated:YES];
                [vc release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else if (indexPath.row == kResize) {
            if (!performingAction) {
                ResizeServerViewController *vc = [[ResizeServerViewController alloc] initWithNibName:@"ResizeServerViewController" bundle:nil];
                vc.serverViewController = self;
                vc.actionIndexPath = indexPath;
                vc.account = account;
                vc.server = server;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    vc.modalPresentationStyle = UIModalPresentationFormSheet;
                }                
                [self.navigationController presentModalViewController:vc animated:YES];
                [vc release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else if (indexPath.row == kRebuild) {
            SimpleImagePickerViewController *vc = [[SimpleImagePickerViewController alloc] initWithNibName:@"SimpleImagePickerViewController" bundle:nil];
            vc.mode = kModeRebuildServer;
            vc.account = self.account;
            vc.selectedImageId = self.server.imageId;
            vc.serverViewController = self;
            vc.delegate = self;
            [self presentModalViewControllerWithNavigation:vc];
            [vc release];            
        } else if (indexPath.row == kChangePassword) {
            if (!performingAction) {
                ResetServerAdminPasswordViewController *vc = [[ResetServerAdminPasswordViewController alloc] initWithNibName:@"ResetServerAdminPasswordViewController" bundle:nil];
                vc.serverViewController = self;
                vc.actionIndexPath = indexPath;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    vc.modalPresentationStyle = UIModalPresentationFormSheet;
                }                
                [self.navigationController presentModalViewController:vc animated:YES];
                [vc release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else if (indexPath.row == kBackups) {            
            if (!performingAction) {
                ManageBackupScheduleViewController *vc = [[ManageBackupScheduleViewController alloc] initWithNibName:@"ManageBackupScheduleViewController" bundle:nil];
                vc.serverViewController = self;
                vc.actionIndexPath = indexPath;
                vc.account = self.account;
                vc.server = self.server;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    vc.modalPresentationStyle = UIModalPresentationFormSheet;
                }                
                [self.navigationController presentModalViewController:vc animated:YES];
                [vc release];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        } else if (indexPath.row == kDelete) {
            if (!performingAction) {
                [deleteActionSheet showInView:self.view];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)changeAdminPassword:(NSString *)password {
    [self showToolbarActivityMessage:@"Changing password..."];        
    performingAction = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
    
    // handle success
    changeAdminPasswordSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"changeAdminPasswordSucceeded" object:self.server
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                               {
                                   [self hideToolbarActivityMessage];
                                   performingAction = NO;
                                   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
                                   [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordSucceededObserver];
                                   [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordFailedObserver];
                               }];
    
    // handle failure
    changeAdminPasswordFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"changeAdminPasswordFailed" object:self.server 
                                                                              queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                            {
                                [self alert:@"There was a problem changing the root password." request:[notification.userInfo objectForKey:@"request"]];
                                [self hideToolbarActivityMessage];
                                performingAction = NO;
                                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
                                [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordSucceededObserver];
                                [[NSNotificationCenter defaultCenter] removeObserver:changeAdminPasswordFailedObserver];
                            }];
    
    [self.account.manager changeAdminPassword:self.server password:password];
}

- (void)removeServersListRow {
    if ([self.account.servers count] == 0) {
        [self.serversViewController.tableView reloadData];
    } else {
        [self.serversViewController.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedServerIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteServer {
    [self showToolbarActivityMessage:@"Deleting server..."];        
    performingAction = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];

    // handle success
    deleteServerSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteServerSucceeded" object:self.server
                                                                                              queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [self hideToolbarActivityMessage];
            performingAction = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:self.account.servers];
            [dict removeObjectForKey:[NSNumber numberWithInt:self.server.identifier]];
            self.account.servers = [[NSMutableDictionary alloc] initWithDictionary:dict]; // TODO: release
            [self.account persist];
            [dict release];
             
            self.serversViewController.account.servers = self.account.servers;
            
            if ([self.account.servers count] == 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                // on ipad, delete needs to get rid of the server on the main view
                self.server = nil;
                [self setBackgroundView];
                [self.tableView reloadData];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            [self.serversViewController.tableView selectRowAtIndexPath:selectedServerIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(removeServersListRow) userInfo:nil repeats:NO];

            [[NSNotificationCenter defaultCenter] removeObserver:deleteServerSucceededObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:deleteServerFailedObserver];
        }];
    
    // handle failure
    deleteServerFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteServerFailed" object:self.server 
                                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
         {
             [self alert:@"There was a problem deleting this server." request:[notification.userInfo objectForKey:@"request"]];
             [self hideToolbarActivityMessage];
             performingAction = NO;
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
             [[NSNotificationCenter defaultCenter] removeObserver:deleteServerFailedObserver];
             [[NSNotificationCenter defaultCenter] removeObserver:deleteServerSucceededObserver];
         }];
    
    [self.account.manager deleteServer:self.server];
}

- (void)showAction:(NSString *)name {
    [self showToolbarActivityMessage:name];
    //performingAction = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hideAction {
    [self hideToolbarActivityMessage];
    performingAction = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)renameServer:(NSString *)name {
    [self showAction:@"Renaming server..."];
    [[self.account.manager renameServer:self.server name:name] success:^(OpenStackRequest *request) {
        [self hideAction];
        [self.account refreshCollections];
        self.server.name = name;
        titleView.nameLabel.text = self.server.name;
        [self.serversViewController.tableView reloadData];
    } failure:^(OpenStackRequest *request) {
        [self alert:@"There was a problem renaming this server." request:request];
        [self hideAction];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:ipAddressActionSheet]) {

        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ssh://%@", selectedIPAddress]];
        
        if (buttonIndex == 0) { // Ping IP Address
            PingIPAddressViewController *vc = [[PingIPAddressViewController alloc] initWithNibName:@"PingIPAddressViewController" bundle:nil ipAddress:selectedIPAddress];
            vc.serverViewController = self;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                vc.modalPresentationStyle = UIModalPresentationPageSheet;
            }                
            [self.navigationController presentModalViewController:vc animated:YES];
            [vc release];
        } else if (buttonIndex == 1) { // Copy to Pasteboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:selectedIPAddress];
            [self.tableView deselectRowAtIndexPath:selectedIPAddressIndexPath animated:YES];
        } else if (buttonIndex == 2) {
            UIApplication *application = [UIApplication sharedApplication];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", selectedIPAddress]];
            if ([application canOpenURL:url]) {
                [application openURL:url];
            }
        } else if (buttonIndex == 3 && [application canOpenURL:url]) {
            [application openURL:url];
        } else {
            [self.tableView deselectRowAtIndexPath:selectedIPAddressIndexPath animated:YES];
        }
    } else if ([actionSheet isEqual:rebootActionSheet]) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kReboot inSection:kActions] animated:YES];
        
        if (buttonIndex != 2) {
            [self showToolbarActivityMessage:@"Rebooting..."];        
            performingAction = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
            
            // handle success
            rebootSucceededObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"rebootSucceeded" object:self.server
                                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(pollServer) userInfo:nil repeats:NO];
                [self hideToolbarActivityMessage];
                performingAction = NO;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] removeObserver:rebootSucceededObserver];
                [[NSNotificationCenter defaultCenter] removeObserver:rebootFailedObserver];
            }];
            
            // handle failure
            rebootFailedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"rebootFailed" object:self.server 
                                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [self alert:@"There was a problem rebooting this server." request:[notification.userInfo objectForKey:@"request"]];
                [self hideToolbarActivityMessage];
                performingAction = NO;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kActions] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] removeObserver:rebootSucceededObserver];
                [[NSNotificationCenter defaultCenter] removeObserver:rebootFailedObserver];
            }];
            
            if (buttonIndex == 0) {
                [self.account.manager hardRebootServer:self.server];
            } else if (buttonIndex == 1) {
                [self.account.manager softRebootServer:self.server];
            }
        }

    } else if ([actionSheet isEqual:deleteActionSheet]) {
        if (buttonIndex == 0) {
            [self deleteServer];
        }
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kDelete inSection:kActions] animated:YES];
    }
}

#pragma mark -
#pragma mark Resize Alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.account.manager confirmResizeServer:self.server];
        [self showToolbarActivityMessage:@"Confirming resize..."];
    } else if (buttonIndex == 2) {
        [self.account.manager revertResizeServer:self.server];
        [self showToolbarActivityMessage:@"Reverting resize..."];
    }
}

#pragma - Button Handlers

- (IBAction)rebootButtonPressed:(id)sender {
    if (!performingAction && [rebootCountdown isEqualToString:@""]) {
        [rebootActionSheet showInView:self.view];
    } else if (![rebootCountdown isEqualToString:@""]) {
        [self alert:nil message:@"Reboots are not available because the API rate limit has been reached for this account.  These actions will be available as soon as the countdown reaches zero."];
    }
}

- (IBAction)snapshotButtonPressed:(id)sender {
    
}

- (IBAction)pingIPButtonPressed:(id)sender {
    if ([[server.addresses objectForKey:@"public"] count] > 0) {
        NSString *ipAddress = [[server.addresses objectForKey:@"public"] objectAtIndex:0];
        PingIPAddressViewController *vc = [[PingIPAddressViewController alloc] initWithNibName:@"PingIPAddressViewController" bundle:nil ipAddress:ipAddress];
        vc.serverViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationPageSheet;
        }                
        [self.navigationController presentModalViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [server release];
    [account release];
    [tableView release];
    [selectedIPAddressIndexPath release];
    [ipAddressActionSheet release];
    [rebootActionSheet release];
    [deleteActionSheet release];
    [serversViewController release];
    [selectedServerIndexPath release];
    [progressView release];
    [actionsArrow release];
    [accountHomeViewController release];
    [super dealloc];
}


@end

