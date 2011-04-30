//
//  LoadBalancerProtocol.m
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerProtocol.h"


@implementation LoadBalancerProtocol

@synthesize name, port;

- (void)dealloc {
    [name release];
    [super dealloc];
}

+ (LoadBalancerProtocol *)fromJSON:(NSDictionary *)dict {
    LoadBalancerProtocol *protocol = [[[LoadBalancerProtocol alloc] init] autorelease];
    protocol.name = [dict objectForKey:@"name"];
    protocol.port = [[dict objectForKey:@"port"] intValue];
    return protocol;
}

@end
