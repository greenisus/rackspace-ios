//
//  AddLoadBalancerAlgorithmViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenStackAccount, LoadBalancer;

@interface AddLoadBalancerAlgorithmViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource> {
    OpenStackAccount *account;
    IBOutlet UITableView *tableView;
    IBOutlet UIPickerView *pickerView;
    
    UIImageView *loadBalancerIcon;
    NSMutableArray *serverIcons;
    NSMutableArray *dots;
    LoadBalancer *loadBalancer;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) LoadBalancer *loadBalancer;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

- (id)initWithAccount:(OpenStackAccount *)account;
- (void)animateDots;

@end
