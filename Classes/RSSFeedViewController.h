//
//  RSSFeedViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityIndicatorView;

@interface RSSFeedViewController : UITableViewController {
    NSDictionary *feed;
    ActivityIndicatorView *activityIndicatorView;
    NSMutableArray *feedItems;
    BOOL requestFailed;
}

@property (retain) NSDictionary *feed;
@property (retain) NSMutableArray *feedItems;

@end
