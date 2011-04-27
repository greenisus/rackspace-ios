//
//  UIViewController+Conveniences.m
//
//  Created by Mike Mayo on 7/21/10.
//

#import "UIViewController+Conveniences.h"
#import "NSObject+Conveniences.h"
#import "OpenStackRequest.h"
#import "LogEntryModalViewController.h"
#import "APILogEntry.h"
#import "OpenStackAccount.h"
#import "ServerViewController.h"
#import "OpenStackAppDelegate.h"
#import "UIColor+MoreColors.h"
#import "ErrorAlerter.h"
#import "RootViewController.h"

#define kUpcoming 0
#define kAllEvents 1

@implementation UIViewController (Conveniences)

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];

//    if ([self respondsToSelector:@selector(serverViewController)] && [self respondsToSelector:@selector(actionIndexPath)]) {
//        ServerViewController *vc = (ServerViewController *)[self performSelector:@selector(serverViewController)];
//        [vc.tableView deselectRowAtIndexPath:(NSIndexPath *)[self performSelector:@selector(actionIndexPath)] animated:YES];
//    }    
}

- (void)addCancelButton {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancel;
    [cancel release];
}

- (void)addSaveButton {
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = save;
    [save release];
}

- (void)addAddButton {
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = add;
    [add release];
}

- (void)addDoneButton {
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = done;
    [done release];
}

- (void)addNextButton {
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonPressed:)];
    self.navigationItem.rightBarButtonItem = next;
    [next release];
}

- (void)presentModalViewControllerWithNavigation:(UIViewController *)viewController animated:(BOOL)animated {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.opaque = NO;
    } else {
        nav.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        nav.navigationBar.translucent = self.navigationController.navigationBar.translucent;
        nav.navigationBar.opaque = self.navigationController.navigationBar.opaque;
        nav.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;    
    }
    
    [self.navigationController presentModalViewController:nav animated:animated];
    [nav release];
}

- (void)presentModalViewControllerWithNavigation:(UIViewController *)viewController {
    [self presentModalViewControllerWithNavigation:viewController animated:YES];
}

- (void)presentPrimaryViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // if we're on iphone, do a regular push, on iPad, let's change the split view
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.masterNavigationController.viewControllers = [NSArray arrayWithObject:viewController];
        if (app.rootViewController.popoverController != nil) {
            viewController.navigationItem.leftBarButtonItem = app.barButtonItem;
        }
    } else {
        [self.navigationController pushViewController:viewController animated:animated];
    }
}

- (void)presentPrimaryViewController:(UIViewController *)viewController {
    [self presentPrimaryViewController:viewController animated:YES];
}

- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)alert:(NSString *)message request:(OpenStackRequest *)request {
    ErrorAlerter *alerter = [[ErrorAlerter alloc] init];
    [alerter alert:message request:request viewController:self];
    //[alerter release]; // TODO: restore this 
}

- (void)failOnBadConnection {
    [self alert:@"Connection Error" message:@"Please check your connection or API URL and try again."];
}

- (UITableViewCell *)tableView:(UITableView *)tableView emptyCellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle deleteButtonTitle:(NSString *)deleteButtonTitle deleteButtonSelector:(SEL)deleteButtonSelector {
    static NSString *CellIdentifier = @"EmptyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, tableView.frame.size.height)];
    container.center = cell.center;
    container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    CGRect imageRect = CGRectMake(tableView.frame.size.width / 2.0 - imageView.frame.size.width / 2.0, (tableView.frame.size.height / 2.0 - imageView.frame.size.height / 2.0) - 35.0, imageView.frame.size.width, imageView.frame.size.height);
    
    if (deleteButtonTitle) {
        imageRect = CGRectMake(tableView.frame.size.width / 2.0 - imageView.frame.size.width / 2.0, (tableView.frame.size.height / 2.0 - imageView.frame.size.height / 2.0) - 78.0, imageView.frame.size.width, imageView.frame.size.height);
    }
    
    imageView.frame = imageRect;
    
    [container addSubview:imageView];
    [imageView release];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = CGRectMake(10.0, imageView.frame.origin.y + imageView.frame.size.height + 20.0, tableView.frame.size.width - 20.0, size.height);    
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = font;
    label.textColor = [UIColor emptyCollectionGrayColor];
    label.text = title;
    label.textAlignment = UITextAlignmentCenter;
    [container addSubview:label];
    
    font = [UIFont boldSystemFontOfSize:14.0];
    size = [subtitle sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
    rect = CGRectMake(10.0, rect.origin.y + label.frame.size.height + 8.0, tableView.frame.size.width - 20.0, size.height);    
    
    UILabel *sublabel = [[UILabel alloc] initWithFrame:rect];
    sublabel.numberOfLines = 0;
    sublabel.lineBreakMode = UILineBreakModeWordWrap;
    sublabel.font = font;
    sublabel.textColor = [UIColor emptyCollectionGrayColor];
    sublabel.text = subtitle;
    sublabel.textAlignment = UITextAlignmentCenter;
    [container addSubview:sublabel];
    
    
    if (deleteButtonTitle) {
        rect = CGRectMake(10.0, rect.origin.y + sublabel.frame.size.height + 57.0, 301.0, 43.0);        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = rect;
        deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"red-button.png"] forState:UIControlStateNormal];
        [deleteButton setTitle:deleteButtonTitle forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:deleteButtonSelector forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:deleteButton];
    }
    
    [label release];
    [sublabel release];
    
    [cell addSubview:container];
    [container release];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView emptyCellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self tableView:tableView emptyCellWithImage:image title:title subtitle:subtitle deleteButtonTitle:nil deleteButtonSelector:nil];
}

@end
