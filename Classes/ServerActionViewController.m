//
//  ServerActionViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 2/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServerActionViewController.h"
#import "OpenStackRequest.h"
#import "UIViewController+Conveniences.h"
#import "Server.h"
#import "ServerViewController.h"
#import "OpenStackAppDelegate.h"


@implementation ServerActionViewController

@synthesize serverViewController, actionIndexPath;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark HTTP Request Helpers

-(void)startRequest:(OpenStackRequest *)request {
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(openStackRequestFinished:)];
	[request setDidFailSelector:@selector(openStackRequestFinished:)];
	[request startAsynchronous];
}

-(void)startRequest:(OpenStackRequest *)request finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector {
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(openStackRequestFinished:)];
	[request setDidFailSelector:@selector(openStackRequestFinished:)];	
	request.userInfo = [NSDictionary dictionaryWithObject:NSStringFromSelector(finishSelector) forKey:@"finishSelector"];
	
	[request startAsynchronous];
}


#pragma mark -
#pragma mark HTTP Response Handlers

-(void)openStackRequestFinished:(OpenStackRequest *)request successSelector:(SEL)successSelector {
	if ([request isSuccess]) {
		// call the success selector if it exists
		NSString *finishSelectorString = [request.userInfo objectForKey:@"finishSelector"];
		if (finishSelectorString) {
			SEL finishSelector = NSSelectorFromString(finishSelectorString);
			if ([[request delegate] respondsToSelector:finishSelector]) {
				[[request delegate] performSelector:finishSelector withObject:request];
			}		
		}
		
		[self dismissModalViewControllerAnimated:YES];
	} else {
		
		NSString *title = @"Error";
		NSString *errorMessage = @"There was a problem renaming your server.";
		switch ([request responseStatusCode]) {
			// in all:
			/// 500, 400, others possible: cloudServersFault
			/// 503: serviceUnavailable
			/// 401: unauthorized
			/// 413: overLimit
			
			// in some:
			// 415: badMediaType
			// 405: badMethod
			// 404: itemNotFound
			// 409: buildInProgress
			/// 503: serverCapacityUnavailable
			/// 409: backupOrResizeInProgress		
			// 403: resizeNotAllowed		
			// 501: notImplemented
				
				
			// 400: badRequest
			case 400: // cloudServersFault
				errorMessage = @"There was a problem with your request.  Please verify the validity of the data you entered.";
				break;
			case 500: // cloudServersFault
				errorMessage = @"There was a problem with your request.";
				break;
			case 503:
				errorMessage = @"Your server was not renamed because the service is currently unavailable.  Please try again later.";
				break;				
			case 401:
				title = @"Authentication Failure";
				errorMessage = @"Please check your User Name and API Key.";
				break;
			case 409:
				errorMessage = @"Your server cannot be renamed at the moment because it is currently building.";
				break;
			case 413:
				errorMessage = @"Your server cannot be renamed at the moment because you have exceeded your API rate limit.  Please try again later or contact support for a rate limit increase.";
				break;
			default:
				break;
		}
		[self alert:title message:errorMessage];
	}
}

-(void)openStackRequestFailed:(OpenStackRequest *)request {
	//NSLog(@"Request Failed: %@", [request url]);
	//[self hideSpinnerView];
	NSString *title = @"Connection Failure";
	NSString *errorMessage = @"Please check your connection and try again.";
	[self alert:title message:errorMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (navigationBar) {
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        navigationBar.tintColor = app.navigationController.navigationBar.tintColor;
        navigationBar.translucent = app.navigationController.navigationBar.translucent;
        navigationBar.opaque = app.navigationController.navigationBar.opaque;
        navigationBar.barStyle = app.navigationController.navigationBar.barStyle;    
    }
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
    [serverViewController.tableView deselectRowAtIndexPath:actionIndexPath animated:YES];
}

- (void)dealloc {
	[serverViewController release];
    [actionIndexPath release];
    [super dealloc];
}

#pragma mark -
#pragma mark View Delegate



@end
