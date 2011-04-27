//
//  LoadBalancerUsage.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerUsage.h"
#import "NSObject+NSCoding.h"


@implementation LoadBalancerUsage

@synthesize identifier, averageNumConnections, incomingTransfer, outgoingTransfer, numVips, numPolls, startTime, endTime;

#pragma mark - Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        [self autoDecode:coder];
    }
    
    return self;
}

#pragma mark - Memory Management

- (void)dealloc {
    [identifier release];
    [startTime release];
    [endTime release];
    [super dealloc];
}

@end
