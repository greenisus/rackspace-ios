//
//  LoadBalancerViewController.h
//  OpenStack
//
//  Created by Michael Mayo on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenStackViewController.h"

@class LoadBalancer, NameAndStatusTitleView;

@interface LoadBalancerViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    LoadBalancer *loadBalancer;
    IBOutlet UIView *segmentView;
    NameAndStatusTitleView *titleView;
    CGPoint previousScrollPoint;
    NSInteger mode;

    IBOutlet UIView *tableViewContainer;
    IBOutlet UITableView *detailsTableView;
    IBOutlet UITableView *nodesTableView;
}

@property (retain) LoadBalancer *loadBalancer;
@property (retain) NameAndStatusTitleView *titleView;
@property (retain) IBOutlet UIView *tableViewContainer;
@property (retain) IBOutlet UITableView *detailsTableView;
@property (retain) IBOutlet UITableView *nodesTableView;


-(id)initWithLoadBalancer:(LoadBalancer *)loadBalancer;
- (IBAction)segmentedControlChanged:(UISegmentedControl *)segmentedControl;

@end
