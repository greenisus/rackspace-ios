//
//  ServerActionViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 2/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class ServerViewController;

@interface ServerActionViewController : UIViewController {
	ServerViewController *serverViewController;
    NSIndexPath *actionIndexPath;
    IBOutlet UINavigationBar *navigationBar;
}

@property (retain) ServerViewController *serverViewController;
@property (retain) NSIndexPath *actionIndexPath;

-(void)cancelButtonPressed:(id)sender;

@end
