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

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *ipVersion;

+ (VirtualIP *)fromJSON:(NSDictionary *)dict;

@end
