    //
//  PingIPAddressViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 4/23/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "PingIPAddressViewController.h"
#import "ServerViewController.h"
#import "OpenStackAppDelegate.h"

@implementation PingIPAddressViewController

@synthesize webView, serverViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadPingSite {
    NSString *urlString = [NSString stringWithFormat:@"http://just-ping.com/index.php?vh=%@&s=ping", ipAddress];
    NSURL *url = [NSURL URLWithString:urlString];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [serverViewController.tableView deselectRowAtIndexPath:serverViewController.selectedIPAddressIndexPath animated:YES];
}

- (void)refreshButtonPressed:(id)sender {
    [self loadPingSite];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ipAddress:(NSString *)anIPAddress {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        ipAddress = anIPAddress;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPingSite];

    OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
    navigationBar.tintColor = app.navigationController.navigationBar.tintColor;
    navigationBar.translucent = app.navigationController.navigationBar.translucent;
    navigationBar.opaque = app.navigationController.navigationBar.opaque;
    navigationBar.barStyle = app.navigationController.navigationBar.barStyle;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [webView release];
    [super dealloc];
}


@end
