//
//  LoadBalancerProtocol.h
//  OpenStack
//
//  Created by Michael Mayo on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoadBalancerProtocol : NSObject {
    NSString *name;
    NSInteger port;
}

@property (nonatomic, retain) NSString *name;
@property (assign) NSInteger port;

+ (LoadBalancerProtocol *)fromJSON:(NSDictionary *)dict;

@end
