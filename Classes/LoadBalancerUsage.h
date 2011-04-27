//
//  LoadBalancerUsage.h
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadBalancerUsage : NSObject <NSCoding> {
    NSString *identifier;
    double averageNumConnections;
    unsigned long long incomingTransfer;
    unsigned long long outgoingTransfer;
    NSInteger numVips;
    NSInteger numPolls;
    NSDate *startTime;
    NSDate *endTime;
}

@property (retain) NSString *identifier;
@property (assign) double averageNumConnections;
@property (assign) unsigned long long incomingTransfer;
@property (assign) unsigned long long outgoingTransfer;
@property (assign) NSInteger numVips;
@property (assign) NSInteger numPolls;
@property (retain) NSDate *startTime;
@property (retain) NSDate *endTime;

@end
