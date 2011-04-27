//
//  VirtualIP.m
//  OpenStack
//
//  Created by Michael Mayo on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VirtualIP.h"
#import "NSObject+NSCoding.h"


@implementation VirtualIP

@synthesize identifier, address, type, ipVersion;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (VirtualIP *)fromJSON:(NSDictionary *)dict {
    VirtualIP *virtualIP = [[[VirtualIP alloc] init] autorelease];
    virtualIP.identifier = [dict objectForKey:@"id"];
    virtualIP.address = [dict objectForKey:@"address"];
    virtualIP.type = [dict objectForKey:@"type"];
    virtualIP.ipVersion = [dict objectForKey:@"ipVersion"];
    return virtualIP;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [identifier release];
    [address release];
    [type release];
    [super dealloc];
}

@end
