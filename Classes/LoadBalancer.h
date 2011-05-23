//
//  LoadBalancer.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@class LoadBalancerProtocol;

@interface LoadBalancer : ComputeModel <NSCoding> {

    LoadBalancerProtocol *protocol;
    NSString *algorithm;
    NSString *status;
    NSString *virtualIPType;
    NSMutableArray *virtualIPs;
    NSDate *created;
    NSDate *updated;
    NSUInteger maxConcurrentConnections;
    BOOL connectionLoggingEnabled;
    NSMutableArray *nodes;
    NSMutableArray *cloudServerNodes;
    NSString *sessionPersistenceType;    
    NSUInteger connectionThrottleMinConnections;
    NSUInteger connectionThrottleMaxConnections;
    NSUInteger connectionThrottleMaxConnectionRate;
    NSUInteger connectionThrottleRateInterval;
    NSString *clusterName;
    NSInteger progress;
    NSString *region;

/*
ORD Region:
https://ord.loadbalancers.api.rackspacecloud.com/v1.0/420600/

DFW Region:
https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/420600/
*/
}

@property (nonatomic, retain) LoadBalancerProtocol *protocol;
@property (nonatomic, retain) NSString *algorithm;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *virtualIPType;
@property (nonatomic, retain) NSMutableArray *virtualIPs;
@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSDate *updated;
@property (nonatomic, assign) NSUInteger maxConcurrentConnections;
@property (nonatomic, assign) BOOL connectionLoggingEnabled;
@property (nonatomic, retain) NSMutableArray *nodes;
@property (nonatomic, retain) NSMutableArray *cloudServerNodes;
@property (nonatomic, retain) NSString *sessionPersistenceType;    
@property (nonatomic, assign) NSUInteger connectionThrottleMinConnections;
@property (nonatomic, assign) NSUInteger connectionThrottleMaxConnections;
@property (nonatomic, assign) NSUInteger connectionThrottleMaxConnectionRate;
@property (nonatomic, assign) NSUInteger connectionThrottleRateInterval;
@property (nonatomic, retain) NSString *clusterName;
@property (nonatomic, assign) NSInteger progress;
@property (nonatomic, assign) NSString *region;

+ (LoadBalancer *)fromJSON:(NSDictionary *)dict;
- (BOOL)shouldBePolled;
- (NSString *)toJSON;

@end
