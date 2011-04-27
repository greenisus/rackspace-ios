//
//  LoadBalancer.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@interface LoadBalancer : ComputeModel <NSCoding> {

    NSString *protocol;
    NSUInteger port;
    NSString *algorithm;
    NSString *status;
    NSMutableArray *virtualIPs;
    NSDate *created;
    NSDate *updated;
    NSUInteger maxConcurrentConnections;
    BOOL connectionLoggingEnabled;
    NSMutableArray *nodes;
    NSString *sessionPersistenceType;    
    NSUInteger connectionThrottleMinConnections;
    NSUInteger connectionThrottleMaxConnections;
    NSUInteger connectionThrottleMaxConnectionRate;
    NSUInteger connectionThrottleRateInterval;
    NSString *clusterName;
    NSInteger progress;

/*
ORD Region:
https://ord.loadbalancers.api.rackspacecloud.com/v1.0/420600/

DFW Region:
https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/420600/
*/
}

@property (retain) NSString *protocol;
@property (assign) NSUInteger port;
@property (retain) NSString *algorithm;
@property (retain) NSString *status;
@property (retain) NSMutableArray *virtualIPs;
@property (retain) NSDate *created;
@property (retain) NSDate *updated;
@property (assign) NSUInteger maxConcurrentConnections;
@property (assign) BOOL connectionLoggingEnabled;
@property (retain) NSMutableArray *nodes;
@property (retain) NSString *sessionPersistenceType;    
@property (assign) NSUInteger connectionThrottleMinConnections;
@property (assign) NSUInteger connectionThrottleMaxConnections;
@property (assign) NSUInteger connectionThrottleMaxConnectionRate;
@property (assign) NSUInteger connectionThrottleRateInterval;
@property (retain) NSString *clusterName;
@property (assign) NSInteger progress;

+ (LoadBalancer *)fromJSON:(NSDictionary *)dict;
- (BOOL)shouldBePolled;
- (NSString *)toJSON;

@end
