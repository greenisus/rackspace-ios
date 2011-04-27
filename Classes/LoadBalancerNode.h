//
//  LoadBalancerNode.h
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadBalancerNode : NSObject {
    NSString *identifier;
    NSString *address;
    NSString *port;
    NSString *condition;
    NSString *status;
}

@property (retain) NSString *identifier;
@property (retain) NSString *address;
@property (retain) NSString *port;
@property (retain) NSString *condition;
@property (retain) NSString *status;

+ (LoadBalancerNode *)fromJSON:(NSDictionary *)dict;

@end
