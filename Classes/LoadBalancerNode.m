//
//  LoadBalancerNode.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerNode.h"
#import "NSObject+NSCoding.h"


@implementation LoadBalancerNode

@synthesize identifier, address, port, condition, status;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (LoadBalancerNode *)fromJSON:(NSDictionary *)dict {
    LoadBalancerNode *node = [[[LoadBalancerNode alloc] init] autorelease];
    node.identifier = [dict objectForKey:@"id"];
    node.address = [dict objectForKey:@"address"];
    node.condition = [dict objectForKey:@"condition"];
    node.status = [dict objectForKey:@"status"];
    return node;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [identifier release];
    [address release];
    [port release];
    [condition release];
    [status release];
    [super dealloc];
}

@end
