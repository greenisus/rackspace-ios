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

@property (retain) OpenStackAccount *account;
@property (retain) LoadBalancer *loadBalancer;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) IBOutlet UIPickerView *pickerView;

- (id)initWithAccount:(OpenStackAccount *)account;
- (void)animateDots;

@end
