//
//  VirtualIP.h
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VirtualIP : NSObject <NSCoding> {
    NSString *identifier;
    NSString *address;
    NSString *type;
    NSString *ipVersion;
}

@property (retain) NSString *identifier;
@property (retain) NSString *address;
@property (retain) NSString *type;
@property (retain) NSString *ipVersion;

+ (VirtualIP *)fromJSON:(NSDictionary *)dict;

@end
