//
//  ImageFamilyPickerCell.h
//  OpenStack
//
//  Created by Mike Mayo on 10/23/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

#define kImageFamilyPickerCellHeight 85.0

@class OpenStackAccount;

@interface ImageFamilyPickerCell : UITableViewCell <UIPickerViewDelegate, UIPickerViewDataSource> {
    OpenStackAccount *account;
    NSDictionary *images;
    NSString *selectedFamily;
    UITableView *tableView;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDictionary *images;
@property (nonatomic, retain) NSString *selectedFamily;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier account:(OpenStackAccount *)openStackAccount tableView:(UITableView *)aTableView;

@end
