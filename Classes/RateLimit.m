//
//  RateLimit.m
//  OpenStack
//
//  Created by Mike Mayo on 12/3/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "RateLimit.h"
#import "NSObject+NSCoding.h"


@implementation RateLimit

@synthesize unit, remaining, verb, regex, value, resetTime, uri;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeObject:unit forKey:@"unit"];
    [coder encodeInt:remaining forKey:@"remaining"];
    [coder encodeObject:verb forKey:@"verb"];
    [coder encodeObject:regex forKey:@"regex"];
    [coder encodeInt:value forKey:@"value"];
    [coder encodeObject:resetTime forKey:@"resetTime"];
    [coder encodeObject:uri forKey:@"uri"];
     */
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        unit = [[coder decodeObjectForKey:@"unit"] retain];
        remaining = [coder decodeIntForKey:@"remaining"];
        verb = [[coder decodeObjectForKey:@"verb"] retain];
        regex = [[coder decodeObjectForKey:@"regex"] retain];
        value = [coder decodeIntForKey:@"value"];
        resetTime = [[coder decodeObjectForKey:@"resetTime"] retain];
        uri = [[coder decodeObjectForKey:@"uri"] retain];
         */
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (RateLimit *)fromJSON:(NSDictionary *)dict {
    
    RateLimit *rateLimit = [[[RateLimit alloc] init] autorelease];
    rateLimit.unit = [dict objectForKey:@"unit"];
    rateLimit.remaining = [[dict objectForKey:@"remaining"] intValue];
    rateLimit.verb = [dict objectForKey:@"verb"];
    rateLimit.regex = [dict objectForKey:@"regex"];
    rateLimit.value = [[dict objectForKey:@"value"] intValue];
    rateLimit.resetTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"resetTime"] intValue]];    
    rateLimit.uri = [dict objectForKey:@"URI"];
    
    return rateLimit;
}

#pragma mark -
#pragma mark Comparison

// rate limits should be sorted by verb + uri
- (NSComparisonResult)compare:(RateLimit *)aRateLimit {
    return [[NSString stringWithFormat:@"%@ %@", self.verb, self.uri] compare:[NSString stringWithFormat:@"%@ %@", aRateLimit.verb, aRateLimit.uri]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [unit release];
    [verb release];
    [regex release];
    [resetTime release];
    [uri release];
    [super dealloc];
}

@end
