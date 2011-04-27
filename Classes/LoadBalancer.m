//
//  LoadBalancer.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancer.h"
#import "VirtualIP.h"
#import "LoadBalancerNode.h"
#import "NSObject+NSCoding.h"


@implementation LoadBalancer

@synthesize protocol, port, algorithm, status, virtualIPs, created, updated, maxConcurrentConnections,
            connectionLoggingEnabled, nodes, connectionThrottleMinConnections,
            connectionThrottleMaxConnections, connectionThrottleMaxConnectionRate,
            connectionThrottleRateInterval, clusterName, sessionPersistenceType, progress;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];    
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (LoadBalancer *)fromJSON:(NSDictionary *)dict {
    LoadBalancer *loadBalancer = [[[LoadBalancer alloc] initWithJSONDict:dict] autorelease];
    loadBalancer.protocol = [dict objectForKey:@"protocol"];
    loadBalancer.port = [loadBalancer intForKey:@"port" inDict:dict];
    loadBalancer.algorithm = [dict objectForKey:@"algorithm"];
    loadBalancer.status = [dict objectForKey:@"status"];
    
    NSArray *virtualIpDicts = [dict objectForKey:@"virtualIps"];
    loadBalancer.virtualIPs = [[NSMutableArray alloc] initWithCapacity:[virtualIpDicts count]];
    for (NSDictionary *vipDict in virtualIpDicts) {
        VirtualIP *ip = [VirtualIP fromJSON:vipDict];
        [loadBalancer.virtualIPs addObject:ip];
    }
    
    loadBalancer.created = [loadBalancer dateForKey:@"time" inDict:[dict objectForKey:@"created"]];
    loadBalancer.updated = [loadBalancer dateForKey:@"time" inDict:[dict objectForKey:@"updated"]];

    // TODO: loadBalancer.maxConcurrentConnections = 
    
    loadBalancer.connectionLoggingEnabled = [[[dict objectForKey:@"connectionLogging"] objectForKey:@"enabled"] boolValue];

    NSArray *nodeDicts = [dict objectForKey:@"nodes"];
    loadBalancer.nodes = [[NSMutableArray alloc] initWithCapacity:[nodeDicts count]];
    for (NSDictionary *nodeDict in nodeDicts) {
        LoadBalancerNode *node = [LoadBalancerNode fromJSON:nodeDict];
        [loadBalancer.nodes addObject:node];
    }
    
    loadBalancer.connectionThrottleMinConnections = [loadBalancer intForKey:@"minConnections" inDict:[dict objectForKey:@"connectionThrottle"]];
    loadBalancer.connectionThrottleMaxConnections = [loadBalancer intForKey:@"maxConnections" inDict:[dict objectForKey:@"connectionThrottle"]];
    loadBalancer.connectionThrottleMaxConnectionRate = [loadBalancer intForKey:@"maxConnectionRate" inDict:[dict objectForKey:@"connectionThrottle"]];
    loadBalancer.connectionThrottleRateInterval = [loadBalancer intForKey:@"rateInterval" inDict:[dict objectForKey:@"connectionThrottle"]];    
    loadBalancer.sessionPersistenceType = [[dict objectForKey:@"sessionPersistence"] objectForKey:@"persistenceType"];
    loadBalancer.clusterName = [[dict objectForKey:@"cluster"] objectForKey:@"name"];
    return loadBalancer;
}

- (NSString *)toJSON {
    
    NSString *json = @"{ \"loadBalancer\": { ";

    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"name\": \"%@\", ", self.name]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"protocol\": \"%@\", ", self.protocol]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%@\", ", self.port]];
    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"algorithm\": \"%@\", ", self.algorithm]];
    
    json = [json stringByAppendingString:@"\"virtualIps\": ["];
    for (int i = 0; i < [self.virtualIPs count]; i++) {
        VirtualIP *vip = [self.virtualIPs objectAtIndex:i];
        json = [json stringByAppendingString:@"{"];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"type\": \"%@\"", vip.type]];
        json = [json stringByAppendingString:i == [self.virtualIPs count] - 1 ? @"}" : @"}, "];
    }
    json = [json stringByAppendingString:@"]"];
    
    json = [json stringByAppendingString:@"\"nodes\": ["];
    for (int i = 0; i < [self.nodes count]; i++) {
        LoadBalancerNode *node = [self.nodes objectAtIndex:i];
        json = [json stringByAppendingString:@"{"];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"address\": \"%@\",", node.address]];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"port\": \"%@\",", node.port]];
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"condition\": \"%@\"", node.condition]];
        json = [json stringByAppendingString:i == [self.nodes count] - 1 ? @"}" : @"}, "];
    }
    json = [json stringByAppendingString:@"]"];
    
    json = [json stringByAppendingString:@"}}"];
    return json;
}

- (BOOL)shouldBePolled {
    return ![self.status isEqualToString:@"ACTIVE"];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [protocol release];
    [algorithm release];
    [status release];
    [virtualIPs release];
    [created release];
    [updated release];
    [nodes release];
    [sessionPersistenceType release];
    [clusterName release];
    [super dealloc];
}

@end
