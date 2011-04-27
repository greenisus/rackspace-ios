//
//  ContactInformationViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ContactInformationViewController.h"
#import "Provider.h"
#import "UIColor+MoreColors.h"


@implementation ContactInformationViewController

@synthesize provider;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Fanatical Support";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *backgroundContainer = [[UIView alloc] init];
        backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        NSString *logoFilename = @"contact-rackspace-icon-large.png";
        UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
        osLogo.contentMode = UIViewContentModeScaleAspectFit;
        osLogo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            osLogo.alpha = 0.3;
        }
        [backgroundContainer addSubview:osLogo];
        [osLogo release];
        self.tableView.backgroundView = backgroundContainer;
        [backgroundContainer release];
    } 
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [provider.contactURLs count] : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1 : [provider.contactURLs count];
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
    
    // Configure the cell...
    NSDictionary *contactURL = [provider.contactURLs objectAtIndex:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? indexPath.section : indexPath.row];
    cell.textLabel.text = [contactURL objectForKey:@"name"];
    cell.detailTextLabel.text = [contactURL objectForKey:@"url"];
	
    NSURL* url = [NSURL URLWithString:[contactURL objectForKey:@"url"]];

    // Check the shared applications for registerd URLs and
    // if the handler found highlight the URL
    UIApplication* application = [UIApplication sharedApplication];
	
    // if it's a link to twitter, let's see if the device has the Twitter app
    // installed and use that instead
    if ([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"www.twitter.com"] && ![url.path isEqualToString:@""]) {
        cell.imageView.image = [UIImage imageNamed:@"twitter-icon.png"];
        NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:@%@", [url.path substringFromIndex:1]]];
        if ([application canOpenURL:twitterURL]) {
            url = twitterURL;
        }
    }
    
    if ([[contactURL objectForKey:@"name"] isEqualToString:@"US Phone Support"]) {
        if ([application canOpenURL:url]) {
            cell.textLabel.text = @"Call US Support";
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text = @"US Support";
            cell.detailTextLabel.text = @"877-934-0407";
        }
        cell.imageView.image = [UIImage imageNamed:@"us-phone-support-icon.png"];
    } else if ([[contactURL objectForKey:@"name"] isEqualToString:@"UK Phone Support"]) {
        if ([application canOpenURL:url]) {
            cell.textLabel.text = @"Call UK Support";
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text = @"UK Support";
            cell.detailTextLabel.text = @"0800-083-3012";
        }
        cell.imageView.image = [UIImage imageNamed:@"uk-phone-support-icon.png"];
    } else if ([[contactURL objectForKey:@"name"] isEqualToString:@"Rackspace on Twitter"]) {
        cell.detailTextLabel.text = @"";
    }
    
    if ([application canOpenURL:url]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		
    NSDictionary *contactItem = [provider.contactURLs objectAtIndex:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? indexPath.section : indexPath.row];

    selectedURL = [NSURL URLWithString:[contactItem objectForKey:@"url"]];

    // Check the shared applications for registerd URLs and
    // try to open the requested url with appropriate application
    UIApplication *application = [UIApplication sharedApplication];
    
    // if it's a link to twitter, let's see if the device has the Twitter app
    // installed and use that instead
    if ([selectedURL.host isEqualToString:@"twitter.com"] || [selectedURL.host isEqualToString:@"www.twitter.com"] && ![selectedURL.path isEqualToString:@""]) {
        NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:@%@", [selectedURL.path substringFromIndex:1]]];
        if ([application canOpenURL:twitterURL]) {
            selectedURL = twitterURL;
        }
    }
    
    if ([application canOpenURL:selectedURL]) {
        [application openURL:selectedURL];            
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    selectedIndexPath = indexPath;
    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [provider release];
    [super dealloc];
}

@end
