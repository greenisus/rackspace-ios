//
//  LogEntryModalViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "LogEntryModalViewController.h"
#import "APILogEntry.h"
#import "TextViewCell.h"

#define kRequest 0
#define kResponse 1

@implementation LogEntryModalViewController


@synthesize logEntry, requestDescription, responseDescription, requestMethod, url;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Button Handlers

- (void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)emailLogEntryButtonPressed:(id)sender {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;		
    //[vc setSubject:[NSString stringWithFormat:@"OpenStack Log Entry: %@ %@", logEntry.requestMethod, logEntry.url]];            
    [vc setSubject:[NSString stringWithFormat:@"OpenStack Log Entry: %@ %@", requestMethod, url]];
    //[vc setMessageBody:[NSString stringWithFormat:@"%@\n\n%@", [logEntry requestDescription], [logEntry responseDescription]] isHTML:NO];    
    [vc setMessageBody:[NSString stringWithFormat:@"%@\n\n%@", requestDescription, responseDescription] isHTML:NO];    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationPageSheet;
    }                
    [self presentModalViewController:vc animated:YES];
    [vc release];        
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
        //text = [logEntry requestDescription];
        text = requestDescription;
    } else if (indexPath.section == kResponse) {
        //text = [logEntry responseDescription];
        text = responseDescription;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

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
        cell.textLabel.text = requestDescription;
    } else if (indexPath.section == kResponse) {
        cell.textLabel.text = responseDescription;
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

- (void)dealloc {
    [logEntry release];
    [requestDescription release];
    [responseDescription release];
    [requestMethod release];
    [url release];
    [super dealloc];
}


@end
