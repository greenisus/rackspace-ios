//
//  ImagePickerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/25/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount;

@interface ImagePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UITableView *tableView;
	NSUInteger selectedImageId;
    OpenStackAccount *account;    
    NSDictionary *images;
    NSString *selectedFamily;
}

@property (retain) OpenStackAccount *account;
@property (retain) IBOutlet UITableView *tableView;

@end
