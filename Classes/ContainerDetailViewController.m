//
//  ContainerDetailViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/22/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ContainerDetailViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "ActivityIndicatorView.h"
#import "AccountManager.h"
#import "UIViewController+Conveniences.h"
#import "UIColor+MoreColors.h"
#import "ReferrerACLViewController.h"
#import "UserAgentACLViewController.h"
#import "ContainersViewController.h"
#import "Folder.h"

#define kOverview 0
#define kCDNAccess 1
#define kCDNAttributes 2
#define kLogRetention 3
#define kReferrerACL 4
#define kUserAgentACL 5

/*
 #define kOverview 0
 #define kCDNAccess 1
 #define kCDNAttributes 2
 #define kLogRetention 3
 #define kReferrerACL 4
 #define kUserAgentACL 5
 Name
 Size
 
 Publish to CDN [On/Off]
 @"Containers published to the CDN will be viewable to everyone.  If you disable CDN access, container contents will not be purged from the CDN until the TTL expires."
 
 CDN URL
 TTL
 
 Log Retention [On/Off]
 @"When Log Retention is enabled, CDN access logs will be stored in the .CDN_ACCESS_LOGS container in your account."
 
 Referrer ACL
 @"The Referrer ACL is a Perl Compatible Regular Expression (PCRE) that must match the referrer in order for container contents to be served.  This is a useful mechanism to prevent other content providers from hot-linking your CDN content."
 
 User Agent ACL
 @"The User Agent ACL is a PCRE that must match the user agent that your users are using to access the CDN content." 
 
 */

@implementation ContainerDetailViewController

@synthesize account, container, containersViewController, selectedContainerIndexPath;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setBackgroundView {
    if (!self.container) {
        UIView *viewContainer = [[UIView alloc] init];
        viewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        viewContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor emptyCollectionGrayColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        label.text = @"No container selected";
        label.textAlignment = UITextAlignmentCenter;
        [viewContainer addSubview:label];
        [label release];
        
        self.tableView.backgroundView = viewContainer;
        [viewContainer release];
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    cdnEnabledSwitch = [[UISwitch alloc] init];
    cdnEnabledSwitch.on = container.cdnEnabled;
    [cdnEnabledSwitch addTarget:self action:@selector(cdnEnabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    logRetentionSwitch = [[UISwitch alloc] init];
    logRetentionSwitch.on = container.logRetention;
    [logRetentionSwitch addTarget:self action:@selector(logRetentionSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    ttlSlider = [[UISlider alloc] init];
    cdnURLActionSheet = [[UIActionSheet alloc] initWithTitle:container.cdnURL delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Pasteboard", nil];
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this container?  This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Container" otherButtonTitles:nil];
    
    deleteSection = container.cdnEnabled ? 6 : 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (container) {
        self.navigationItem.title = container.name;
    } else {
        self.navigationItem.title = @"Cloud Files Container";
    }
    originalTTL = container.ttl;
    [self setBackgroundView];
}

#pragma mark -
#pragma mark TTL

- (float)ttlToPercentage {
    return self.container.ttl / 259200.0;
}

- (NSInteger)ttlFromPercentage:(float)percentage {
    return percentage * 259200;
}

- (NSString *)ttlToHours {
    NSString *result = [NSString stringWithFormat:@"%.0f hours", self.container.ttl / 3600.0];
    if ([result isEqualToString:@"1 hours"]) {
        result = @"1 hour";
    }
    return result;
}

- (void)ttlSliderFinished:(id)sender {
    NSString *activityMessage = @"Updating TTL...";
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
    [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];
    
    [self.account.manager updateCDNContainer:self.container];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [activityIndicatorView removeFromSuperviewAndRelease];
           [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
       }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerFailed" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [activityIndicatorView removeFromSuperviewAndRelease];
           container.ttl = originalTTL;
           [self.tableView reloadData];
           [self alert:@"There was a problem updating this container." request:[notification.userInfo objectForKey:@"request"]];
           [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
       }];
}

- (void)ttlSliderMoved:(id)sender {
	CGFloat newTTL = ttlSlider.value;
    self.container.ttl = [self ttlFromPercentage:newTTL];
    ttlLabel.text = [self ttlToHours];
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textLabelSize = CGSizeMake(577.0, 9000.0f);
    } else {
        textLabelSize = CGSizeMake(260.0, 9000.0f);
    }
    // pad \n\n to fix layout bug
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == deleteSection) {
        return tableView.rowHeight;
    } else if (indexPath.section == kCDNAttributes) {
        if (indexPath.row == 0) { // URL
            return tableView.rowHeight;
            //return 22.0 + [self findLabelHeight:container.cdnURL font:[UIFont systemFontOfSize:18.0]];
        } else { // if (indexPath.row == 1) {
            return tableView.rowHeight + ttlSlider.frame.size.height + 3.0;
        }
    } else {
        return tableView.rowHeight;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == deleteSection) {
        return @"Only empty containers can be deleted.";
    } else if (section == kCDNAccess) {
        //return @"CDN allows you to access files in this container via the public internet. Transfer charges apply.";
        return @"CDN allows you to access files via the public internet. Transfer charges apply.";
    } else if (section == kLogRetention) {
        return @"When enabled, access logs will be stored in the .CDN_ACCESS_LOGS container.";
    } else if (section == kReferrerACL) {
        return @"The Referrer ACL is a Perl Compatible Regular Expression that must match the referrer for all content requests.";
    } else if (section == kUserAgentACL) {
        return @"The User Agent ACL is a Perl Compatible Regular Expression that must match the user agent for all content requests.";
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.container) {
        if (transitioning) {
            return container.cdnEnabled ? 3 : 7;
        } else {
            return container.cdnEnabled ? 7 : 3;
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == deleteSection) {
        return 1;
    } else if (section == kOverview) {
        return 2;
    } else if (section == kCDNAccess) {
        return 1;
    } else if (section == kCDNAttributes) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView ttlCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TTLCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 280.0, 20.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabel.frame = CGRectMake(54.0, 13.0, 458.0, 20.0);
        }
        textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        textLabel.text = @"TTL";
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:textLabel];
        [textLabel release];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ttlSlider.frame = CGRectMake(54.0, 38.0, 596.0, ttlSlider.frame.size.height);
        } else {
            ttlSlider.frame = CGRectMake(20.0, 38.0, 280.0, ttlSlider.frame.size.height);
        }
        [ttlSlider addTarget:self action:@selector(ttlSliderMoved:) forControlEvents:UIControlEventValueChanged];
        [ttlSlider addTarget:self action:@selector(ttlSliderFinished:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:ttlSlider];
        ttlLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 280.0, 18.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            ttlLabel.frame = CGRectMake(54.0, 14.0, 596.0, 18.0);
        }
        ttlLabel.font = [UIFont systemFontOfSize:17.0];
        ttlLabel.textColor = [UIColor value1DetailTextLabelColor];
        ttlLabel.backgroundColor = [UIColor clearColor];
        ttlLabel.textAlignment = UITextAlignmentRight;
        [cell addSubview:ttlLabel];
    }
    
    ttlLabel.text = [self ttlToHours];
    ttlSlider.value = [self ttlToPercentage];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView deleteCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeleteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = @"Delete Container";
    }
    
    if (self.container.rootFolder) {
        if (self.container.count == 0 || ([self.container.rootFolder.folders count] + [self.container.rootFolder.objects count] == 0)) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        if (self.container.count == 0) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == kOverview) {
        cell.accessoryView = nil;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = container.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [container humanizedSize];
        }
    } else if (indexPath.section == kCDNAccess) {
        cell.textLabel.text = @"Publish to CDN";
        cell.detailTextLabel.text = @"";
        cell.accessoryView = cdnEnabledSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == deleteSection) {
        return [self tableView:tableView deleteCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kCDNAttributes) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Public URL";
            //cell.detailTextLabel.text = container.cdnURL;
            cell.detailTextLabel.text = @"";
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
            cell.detailTextLabel.numberOfLines = 0;
            //cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        } else if (indexPath.row == 1) {
            return [self tableView:tableView ttlCellForRowAtIndexPath:indexPath];
        }
    } else if (indexPath.section == kLogRetention) {
        cell.textLabel.text = @"Log Retention";
        cell.detailTextLabel.text = @"";
        cell.accessoryView = logRetentionSwitch;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == kReferrerACL) {
        cell.textLabel.text = @"Referrer ACL";
        cell.detailTextLabel.text = container.referrerACL;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.numberOfLines = 1;
    } else if (indexPath.section == kUserAgentACL) {
        cell.textLabel.text = @"User Agent ACL";
        cell.detailTextLabel.text = container.useragentACL;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.numberOfLines = 1;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == deleteSection) {
        if (self.container.count == 0 || ([self.container.rootFolder.folders count] + [self.container.rootFolder.objects count] == 0)) {
            [deleteActionSheet showInView:self.view];
        }
    } else if (indexPath.section == kCDNAttributes && indexPath.row == 0) {
        [cdnURLActionSheet showInView:self.view];
    } else if (indexPath.section == kReferrerACL) {
        ReferrerACLViewController *vc = [[ReferrerACLViewController alloc] initWithNibName:@"ReferrerACLViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.containerDetailViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewControllerWithNavigation:vc animated:YES];
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }        
        [vc release];
    } else if (indexPath.section == kUserAgentACL) {
        UserAgentACLViewController *vc = [[UserAgentACLViewController alloc] initWithNibName:@"UserAgentACLViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.containerDetailViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewControllerWithNavigation:vc animated:YES];
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }        
        [vc release];
    }
}

#pragma mark -
#pragma mark Switches

- (void)cdnEnabledSwitchChanged:(id)sender {
    
    NSString *activityMessage = @"Disabling CDN Access...";
    if (!container.cdnEnabled) {
        activityMessage = @"Enabling CDN Access...";
    }
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
    [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];    
    container.cdnEnabled = !container.cdnEnabled;
    [self.account.manager updateCDNContainer:container];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
    {
        [activityIndicatorView removeFromSuperviewAndRelease];
        
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)];
        NSInteger oldDeleteSection = deleteSection;
        if (container.cdnEnabled) {
            deleteSection = 6;
            transitioning = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldDeleteSection, 1)] withRowAnimation:UITableViewRowAnimationBottom];
            transitioning = NO;
            [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            deleteSection = 2;
            transitioning = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(deleteSection, 1)] withRowAnimation:UITableViewRowAnimationTop];
            transitioning = NO;
            [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerFailed" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
    {
        [activityIndicatorView removeFromSuperviewAndRelease];
        container.cdnEnabled = !container.cdnEnabled;
        cdnEnabledSwitch.on = !cdnEnabledSwitch.on;
        [self alert:@"There was a problem updating this container." request:[notification.userInfo objectForKey:@"request"]];           
        [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
    }];
}

- (void)logRetentionSwitchChanged:(id)sender {

    NSString *activityMessage = @"Disabling Log Retention...";
    if (!container.logRetention) {
        activityMessage = @"Enabling Log Retention...";
    }
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
    [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];    

    container.logRetention = !container.logRetention;
    [self.account.manager updateCDNContainer:container];
    
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [activityIndicatorView removeFromSuperviewAndRelease];
           [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
       }];
    
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"updateCDNContainerFailed" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [activityIndicatorView removeFromSuperviewAndRelease];
           container.logRetention = !container.logRetention;
           logRetentionSwitch.on = !logRetentionSwitch.on;
           [self alert:@"There was a problem updating this container." request:[notification.userInfo objectForKey:@"request"]];
           [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
       }];
}

#pragma mark -
#pragma mark Action Sheet

- (void)deleteContainerRow {
    if ([self.account.containers count] == 0) {
        [self.containersViewController.tableView reloadData];
    } else {
        [self.containersViewController.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedContainerIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:cdnURLActionSheet]) {
        if (buttonIndex == 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:container.cdnURL];
        }
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kCDNAttributes] animated:YES];
    } else if ([actionSheet isEqual:deleteActionSheet]) {
        if (buttonIndex == 0) {
         
            NSString *activityMessage = @"Deleting container...";
            activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
            [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];    
            
            [self.account.manager deleteContainer:self.container];
            
            successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteContainerSucceeded" object:self.container
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [activityIndicatorView removeFromSuperviewAndRelease];

                [self.account.containers removeObjectForKey:self.container.name];
                [self.account persist];
                
                
                if ([self.account.containers count] == 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    // on ipad, delete needs to get rid of the container on the main view
                    self.container = nil;
                    [self setBackgroundView];
                    [self.tableView reloadData];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [self.containersViewController.tableView selectRowAtIndexPath:selectedContainerIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(deleteContainerRow) userInfo:nil repeats:NO];
                
                [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            }];
            
            failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteContainerFailed" object:self.container
                                                                                 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [activityIndicatorView removeFromSuperviewAndRelease];
                [self alert:@"There was a problem deleting this container." request:[notification.userInfo objectForKey:@"request"]];
                [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
            }];
            
        }
        
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:deleteSection] animated:YES];
    }
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [cdnEnabledSwitch release];
    [ttlSlider release];
    [cdnURLActionSheet release];
    [deleteActionSheet release];
    [containersViewController release];
    [selectedContainerIndexPath release];
    [super dealloc];
}

@end

