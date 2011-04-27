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

@end
