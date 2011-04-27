//
//  LogEntryViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "LogEntryViewController.h"
#import "APILogEntry.h"
#import "TextViewCell.h"
#import "OpenStackAppDelegate.h"

#define kRequest 0
#define kResponse 1

@implementation LogEntryViewController

@synthesize logEntry;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Email Log Entry

// TODO: if the body is huge, leave it out of the view

- (void)emailLogEntry {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;		
    [vc setSubject:[NSString stringWithFormat:@"OpenStack Log Entry: %@ %@", logEntry.requestMethod, logEntry.url]];            
    [vc setMessageBody:[NSString stringWithFormat:@"%@\n\n%@", [logEntry requestDescription], [logEntry responseDescription]] isHTML:NO];    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationPageSheet;
    }                
    [self presentModalViewController:vc animated:YES];
    [vc release];        
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *emailButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailLogEntry)];
    self.navigationItem.rightBarButtonItem = emailButton;
    [emailButton release];
    
    self.navigationItem.title = @"API Log";
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize = CGSizeMake(280.0, 9000.0f);
    // pad \n\n to fix layout bug
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = @"";
    if (indexPath.section == kRequest) {
        text = [logEntry requestDescription];
    } else if (indexPath.section == kResponse) {
        text = [logEntry responseDescription];
    }    
    return 20.0 + [self findLabelHeight:text font:[UIFont fontWithName:@"Courier" size:12.0]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kRequest) {
        return @"Request";
    } else if (section == kResponse) {
        return @"Response";
    } else {
        return @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView actionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:12.0];
        cell.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    }
    
    if (indexPath.section == kRequest) {
        cell.textLabel.text = [logEntry requestDescription];
    } else if (indexPath.section == kResponse) {
        cell.textLabel.text = [logEntry responseDescription];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark Mail Composer Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
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
    [logEntry release];
    [super dealloc];
}


@end

