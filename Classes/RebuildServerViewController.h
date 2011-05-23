//
//  RebuildServerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>
#import "ImagePickerViewController.h"
//#import "ServerActionViewController.h"

@class OpenStackAccount, Server;

//@interface RebuildServerViewController : ServerActionViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource> {
@interface RebuildServerViewController : ImagePickerViewController {
	//NSUInteger selectedImageId;
    //OpenStackAccount *account;
    Server *server;
    //IBOutlet UITableView *tableView;
    
    //NSDictionary *images;
    //NSString *selectedFamily;
}

//@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) Server *server;

-(void)saveButtonPressed:(id)sender;

@end
