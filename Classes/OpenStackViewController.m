//
//  OpenStackViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"
#import "LogEntryModalViewController.h"
#import "OpenStackRequest.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import "APILogEntry.h"
#import "AnimatedProgressView.h"


@implementation OpenStackViewController

@synthesize toolbar, selectedIndexPath;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    if (self.navigationController.navigationBar) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            self.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
            self.toolbar.translucent = self.navigationController.navigationBar.translucent;
            self.toolbar.opaque = self.navigationController.navigationBar.opaque;
            self.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        } else {
            self.toolbar.translucent = NO;
            self.toolbar.opaque = NO;            
            self.toolbar.tintColor = [UIColor blackColor];
        }
    }
    
    toolbarProgressView = [[AnimatedProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    toolbarProgressView.frame = CGRectMake(0.0, 24.0, 185.0, 10.0);
}

- (void)showToolbarActivityMessage:(NSString *)text progress:(BOOL)hasProgress {
    
    if (toolbarMessageVisible) {
        //[self hideToolbarActivityMessage];
        toolbarLabel.text = text;
    } else {
        UIFont *font = [UIFont boldSystemFontOfSize:12.0];
        CGSize stringSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(226.0, 20.0f) lineBreakMode:UILineBreakModeTailTruncation];    
        toolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 12.0, stringSize.width, 20.0)];
        toolbarLabel.textColor = [UIColor whiteColor];
        toolbarLabel.textAlignment = UITextAlignmentLeft;
        toolbarLabel.font = font;
        toolbarLabel.backgroundColor = [UIColor clearColor];
        toolbarLabel.shadowOffset = CGSizeMake(0, -1.0);
        toolbarLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        toolbarLabel.text = text;
        
        NSMutableArray *items;
        
        if (hasProgress) {
            
            //toolbarLabel.frame = CGRectMake(0.0, 2.0, stringSize.width, 20.0);
            toolbarLabel.frame = CGRectMake(0.0, 2.0, 185.0, 20.0);
            toolbarLabel.textAlignment = UITextAlignmentCenter;
            
            UIView *labelWithProgress = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 185.0, 40.0)];
            
            [labelWithProgress addSubview:toolbarLabel];
            [labelWithProgress addSubview:toolbarProgressView];
            
            toolbarLabelItem = [[UIBarButtonItem alloc] initWithCustomView:labelWithProgress];
            //toolbarLabelItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarProgressView];
            
            [toolbarProgressView setProgress:0.40 animated:YES];
            
            items = [NSMutableArray arrayWithArray:toolbar.items];
            
            [items insertObject:toolbarLabelItem atIndex:1];
            
            [labelWithProgress release];
        } else {
            toolbarActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            toolbarActivityIndicatorView.frame = CGRectMake(10.0, 12.0, 20.0, 20.0);
            [toolbarActivityIndicatorView startAnimating];
            
            toolbarActivityIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarActivityIndicatorView];
            toolbarLabelItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarLabel];
            
            items = [NSMutableArray arrayWithArray:toolbar.items];
            
            if ([items count] > 2) {
                [items insertObject:toolbarActivityIndicatorItem atIndex:2];
                [items insertObject:toolbarLabelItem atIndex:3];
            } else {
                [items insertObject:toolbarActivityIndicatorItem atIndex:1];
                [items insertObject:toolbarLabelItem atIndex:2];
            }
        }
        
        toolbar.items = [NSArray arrayWithArray:items];
        
        toolbarMessageVisible = YES;
    }    
}

- (void)showToolbarActivityMessage:(NSString *)text {
    [self showToolbarActivityMessage:text progress:NO];
}

- (void)hideToolbarActivityMessage {

    if (toolbarMessageVisible) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:toolbar.items];
        [items removeObject:toolbarActivityIndicatorItem];
        [items removeObject:toolbarLabelItem];
        toolbar.items = [NSArray arrayWithArray:items];    

        [toolbarActivityIndicatorItem release];
        [toolbarLabelItem release];
        
        [toolbarLabel removeFromSuperview];
        [toolbarLabel release];
        
        [toolbarActivityIndicatorView removeFromSuperview];
        [toolbarActivityIndicatorView release];
        
        toolbarMessageVisible = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (selectedIndexPath && [self respondsToSelector:@selector(tableView)]) {
        UITableView *tv = [self performSelector:@selector(tableView)];
        [tv deselectRowAtIndexPath:selectedIndexPath animated:YES];        
    }
}

- (void)dealloc {
    if (toolbarMessageVisible) {
        [self hideToolbarActivityMessage];
    }
    [toolbarProgressView release];
    [selectedIndexPath release];
    [super dealloc];
}

@end
