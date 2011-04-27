//
//  RateLimit.h
//  OpenStack
//
//  Created by Mike Mayo on 12/3/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>


@interface RateLimit : NSObject <NSCoding> {
    NSString *unit;
    NSInteger remaining;
    NSString *verb;
    NSString *regex;
    NSInteger value;
    NSDate *resetTime;
    NSString *uri;
}

@property (retain) NSString *unit;
@property (assign) NSInteger remaining;
@property (retain) NSString *verb;
@property (retain) NSString *regex;
@property (assign) NSInteger value;
@property (retain) NSDate *resetTime;
@property (retain) NSString *uri;

+ (RateLimit *)fromJSON:(NSDictionary *)dict;

@end
