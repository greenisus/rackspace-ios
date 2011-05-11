//
//  LoadBalancerRequest.h
//  OpenStack
//
//  Created by Michael Mayo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenStackRequest.h"


@interface LoadBalancerRequest : OpenStackRequest {

}

+ (LoadBalancerRequest *)getLoadBalancersRequest:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableDictionary *)loadBalancers;

+ (LoadBalancerRequest *)createLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer endpoint:(NSString *)endpoint;

+ (LoadBalancerRequest *)getLoadBalancerProtocols:(OpenStackAccount *)account endpoint:(NSString *)endpoint;
- (NSMutableArray *)protocols;


@end
