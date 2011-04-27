//
//  OpenStackAppDelegate.m
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackAppDelegate.h"
#import "RootViewController.h"
#import "OpenStackAccount.h"
#import "Keychain.h"

#import "JSON.h"
#import "Server.h"
#import "Archiver.h"
#import "Provider.h"

#import "APILogger.h"
#import "SettingsPluginHandler.h"
#import "AddServerPluginHandler.h"
#import "OpenStackAccount.h"

#import "RSSFeedViewController.h"

#import "RootViewController.h"



@implementation OpenStackAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize splitViewController;
@synthesize masterNavigationController;
@synthesize barButtonItem;
@synthesize rootViewController;

- (void)loadSettingsDefaults {
    
    // if settings haven't been set up yet, let's go ahead and set some sensible defaults
    
    // passcode settings are ALL sensitive, so they will all go in the keychain
    if (![Keychain getStringForKey:@"passcode_lock_passcode_on"]) {
        [Keychain setString:@"NO" forKey:@"passcode_lock_passcode_on"];
    }
    
    if (![Keychain getStringForKey:@"passcode_lock_simple_passcode_on"]) {
        [Keychain setString:@"YES" forKey:@"passcode_lock_simple_passcode_on"];
    }
    
    if (![Keychain getStringForKey:@"passcode_lock_erase_data_on"]) {
        [Keychain setString:@"NO" forKey:@"passcode_lock_erase_data_on"];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults stringForKey:@"api_logging_level"]) {
        [defaults setValue:@"all" forKey:@"api_logging_level"];
    }

    [defaults synchronize];
    
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self loadSettingsDefaults];
    
    rootViewController = [navigationController.viewControllers objectAtIndex:0];
        
    // Add the navigation controller's view to the window and display.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        RSSFeedViewController *vc = [[RSSFeedViewController alloc] initWithNibName:@"RSSFeedViewController" bundle:nil];
        vc.feed = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Cloud Servers Status", @"feed://status.rackspacecloud.com/cloudservers/rss.xml", @"cloud-servers-icon.png", nil] forKeys:[NSArray arrayWithObjects:@"name", @"url", @"logo", nil]];
        
        masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
        masterNavigationController.navigationBar.tintColor = navigationController.navigationBar.tintColor;
        masterNavigationController.navigationBar.translucent = navigationController.navigationBar.translucent;
        masterNavigationController.navigationBar.opaque = navigationController.navigationBar.opaque;
        masterNavigationController.navigationBar.barStyle = navigationController.navigationBar.barStyle;
        
        splitViewController.delegate = [navigationController.viewControllers objectAtIndex:0];
        splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, masterNavigationController, nil];
        
        [window addSubview:splitViewController.view];
        [window makeKeyAndVisible];
    } else {
        [window addSubview:navigationController.view];
        [window makeKeyAndVisible];
    }
    
    serviceUnavailableObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"serviceUnavailable" object:nil
                                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Service Unavailable" message:@"The API is currently unavailable.  Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSNotificationCenter defaultCenter] removeObserver:serviceUnavailableObserver];
    }];
    

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    // TODO: remove this before releasing.  this is for debugging
    /*
    NSArray *accounts = [OpenStackAccount accounts];
    for (OpenStackAccount *account in accounts) {
        account.authToken = @"xxx";
        [account persist];
    }
     */
    
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    // TODO: perhaps this is a good place to release all the stuff allocated in
    // +(void)initialize methods all over the place
    [[APILogger loggerEntries] release];
    [[SettingsPluginHandler plugins] release];
    [[AddServerPluginHandler plugins] release];
    [[OpenStackAccount accounts] release];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
    [splitViewController release];
    [masterNavigationController release];
    [barButtonItem release];
    [rootViewController release];
	[window release];
	[super dealloc];
}


@end

