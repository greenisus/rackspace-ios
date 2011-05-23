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

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *port;
@property (nonatomic, retain) NSString *condition;
@property (nonatomic, retain) NSString *status;

+ (LoadBalancerNode *)fromJSON:(NSDictionary *)dict;

@end
