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
#import "PasscodeViewController.h"
#import "UIViewController+Conveniences.h"
#import "HTNotifier.h"
#import "Analytics.h"

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

- (void)showPasscodeLock {
    if ([[Keychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"]) {
        PasscodeViewController *vc = [[PasscodeViewController alloc] initWithNibName:@"PasscodeViewController" bundle:nil];
        vc.mode = kModeEnterPasscode;
        //vc.rootViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
        }                
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            for (UIViewController *svc in app.splitViewController.viewControllers) {
                svc.view.alpha = 0.0;
            }
            
            // for some reason, this needs to be delayed
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(presentAndRelease:) userInfo:[NSDictionary dictionaryWithObject:vc forKey:@"vc"] repeats:NO];
            
        } else {
            [[self.navigationController topViewController] presentModalViewControllerWithNavigation:vc animated:NO];
            [vc release];
        }
    }
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self setupDependencies];
        
    [self loadSettingsDefaults];
        
    rootViewController = [navigationController.viewControllers objectAtIndex:0];
    OpenStackAppDelegate <UINavigationControllerDelegate> *delegate = self;
    navigationController.delegate = delegate;
        
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

- (void) setupDependencies{
    
#if TARGET_OS_EMBEDDED
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Constants" ofType:@"plist"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        
        NSDictionary *constants = [NSDictionary dictionaryWithContentsOfFile:path];
        
        [HTNotifier startNotifierWithAPIKey:[constants objectForKey:@"HOPTOAD_ACCOUNT_KEY"]
                            environmentName:HTNotifierAppStoreEnvironment];
                
        [[GANTracker sharedTracker] startTrackerWithAccountID:[constants objectForKey:@"ANALYTICS_ACCOUNT_KEY"] dispatchPeriod:10 delegate:nil];
        DispatchAnalytics();

    }
    
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    DispatchAnalytics();
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"already_failed_on_connection"];
    [defaults synchronize];
    
    [self showPasscodeLock];
    DispatchAnalytics();
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

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    TrackViewController(viewController);
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

