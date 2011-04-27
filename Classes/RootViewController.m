//
//  RootViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "RootViewController.h"
#import "ProvidersViewController.h"
#import "AccountHomeViewController.h"
#import "OpenStackAccount.h"
#import "Provider.h"
#import "Archiver.h"
#import "ActivityIndicatorView.h"
#import "UIViewController+Conveniences.h"
#import "SettingsViewController.h"
#import "Keychain.h"
#import "PasscodeViewController.h"
#import "OpenStackAppDelegate.h"


@implementation RootViewController

@synthesize tableView, popoverController, detailItem;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Split view support

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
    }
    
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.barButtonItem = barButtonItem;
    UIViewController *vc = [[[app.splitViewController.viewControllers objectAtIndex:1] viewControllers] lastObject];
    barButtonItem.title = [[[self.navigationController.viewControllers lastObject] navigationItem] title];
    vc.navigationItem.leftBarButtonItem = barButtonItem;
    self.popoverController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {    
    OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.barButtonItem = barButtonItem;
    UIViewController *vc = [[[app.splitViewController.viewControllers objectAtIndex:1] viewControllers] lastObject];
    vc.navigationItem.leftBarButtonItem = nil;
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Button Handlers

- (void)addButtonPressed:(id)sender {
    OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
    ProvidersViewController *vc = [[ProvidersViewController alloc] initWithNibName:@"ProvidersViewController" bundle:nil];
    vc.rootViewController = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        if (app.rootViewController.popoverController != nil) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }                
    [self presentModalViewControllerWithNavigation:vc];
    [vc release];    
}
   
- (void)settingsButtonPressed:(id)sender {

    //self.navigationController.navigationBarHidden = YES;
    
    //UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];

    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavigationController.view.frame = CGRectMake(0.0, 0.0, 320.0, 460.0);
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        settingsNavigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        settingsNavigationController.navigationBar.translucent = self.navigationController.navigationBar.translucent;
        settingsNavigationController.navigationBar.opaque = self.navigationController.navigationBar.opaque;
        settingsNavigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    } else {
        settingsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
        settingsNavigationController.navigationBar.opaque = NO;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.popoverController != nil) {
            [self.popoverController dismissPopoverAnimated:YES];
        }        
        settingsNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:settingsNavigationController animated:YES];
    } else {
        settingsNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:settingsNavigationController animated:YES];
    }
    
    [settingsViewController release];
    [settingsNavigationController release];
    
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self.tableView setEditing:editing animated:animated];
    [super setEditing:editing animated:animated];
}

- (void)presentAndRelease:(NSTimer *)timer {
    UIViewController *vc = [timer.userInfo objectForKey:@"vc"];
    [self presentModalViewControllerWithNavigation:vc animated:NO];
    [vc release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Accounts";

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    if ([[OpenStackAccount accounts] count] == 0) {
        // if there are no accounts, go straight to the add account screen on launch
        ProvidersViewController *vc = [[ProvidersViewController alloc] initWithNibName:@"ProvidersViewController" bundle:nil];
        vc.rootViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [self presentModalViewControllerWithNavigation:vc animated:NO];
        [vc release];

    } else if ([[OpenStackAccount accounts] count] == 1 && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        // if there's only one account, go to its home screen
        // NOTE: not doing this on iPad because it screws up the split view controller.
        // TODO: make this work well with split view on iPad
        AccountHomeViewController *vc = [[AccountHomeViewController alloc] initWithNibName:@"AccountHomeViewController" bundle:nil];
        vc.account = [[OpenStackAccount accounts] objectAtIndex:0];
        vc.rootViewController = self;
        vc.rootViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.navigationController pushViewController:vc animated:NO];
        [vc release];
    }

    if ([[Keychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"]) {
        PasscodeViewController *vc = [[PasscodeViewController alloc] initWithNibName:@"PasscodeViewController" bundle:nil];
        vc.mode = kModeEnterPasscode;
        vc.rootViewController = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
        }                
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            
//            [self presentModalViewController:vc animated:NO];
//            
//            //            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
//            //            for (UIViewController *svc in app.splitViewController.viewControllers) {
//            //                //svc.view.alpha = 0.0;
//            //            }
//            //            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Enter your passcode" message:nil delegate:nil cancelButtonTitle:@"Awww yeah" otherButtonTitles:nil];
//            //            CGRect rect = av.frame;
//            //            rect.size.width += 200.0;
//            //            rect.size.height += 200.0;
//            //            av.frame = rect;
//            //            [av show];
//            //            [av release];
//            
            
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            for (UIViewController *svc in app.splitViewController.viewControllers) {
                svc.view.alpha = 0.0;
            }
            
            // for some reason, this needs to be delayed
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(presentAndRelease:) userInfo:[NSDictionary dictionaryWithObject:vc forKey:@"vc"] repeats:NO];
            
        } else {
            [self presentModalViewControllerWithNavigation:vc animated:NO];
            [vc release];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[OpenStackAccount accounts] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
    OpenStackAccount *account = [[OpenStackAccount accounts] objectAtIndex:indexPath.row];
    cell.textLabel.text = account.username;
    cell.detailTextLabel.text = account.provider.name;
        
    if (account.provider.logoURLs && [account.provider.logoURLs objectForKey:@"provider_icon"]) {
        cell.imageView.image = [UIImage imageNamed:[account.provider.logoURLs objectForKey:@"provider_icon"]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"openstack-icon.png"];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *accounts = [NSMutableArray arrayWithArray:[OpenStackAccount accounts]];
        [[accounts objectAtIndex:indexPath.row] setFlaggedForDelete:YES];
        [accounts removeObjectAtIndex:indexPath.row];
        [OpenStackAccount persist:accounts];

        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[OpenStackAccount accounts]];
    OpenStackAccount *account = [accounts objectAtIndex:fromIndexPath.row];
    [accounts removeObjectAtIndex:fromIndexPath.row];
    [accounts insertObject:account atIndex:toIndexPath.row];
    [OpenStackAccount persist:accounts];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountHomeViewController *vc = [[AccountHomeViewController alloc] initWithNibName:@"AccountHomeViewController" bundle:nil];
    vc.account = [[OpenStackAccount accounts] objectAtIndex:indexPath.row];
    vc.account.hasBeenRefreshed = NO;
    vc.rootViewController = self;
    vc.rootViewIndexPath = indexPath;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
    [tableView release];
    [popoverController release];
    [detailItem release];     
    [super dealloc];
}


@end

