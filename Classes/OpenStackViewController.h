//
//  OpenStackViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackRequest, LogEntryModalViewController, AnimatedProgressView;

@interface OpenStackViewController : UIViewController {
    IBOutlet UIToolbar *toolbar;
    UILabel *toolbarLabel;
    UIActivityIndicatorView *toolbarActivityIndicatorView;    
    UIBarButtonItem *toolbarActivityIndicatorItem;
    UIBarButtonItem *toolbarLabelItem;
    BOOL toolbarMessageVisible;
    AnimatedProgressView *toolbarProgressView;
    
    OpenStackRequest *failedRequest;
    
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

// assumes the first two items in the toolbar are flexible width spaces
- (void)showToolbarActivityMessage:(NSString *)text progress:(BOOL)hasProgress;
- (void)showToolbarActivityMessage:(NSString *)text;

- (void)hideToolbarActivityMessage;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;


@end
