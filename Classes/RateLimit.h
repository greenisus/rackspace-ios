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

@property (nonatomic, retain) NSString *unit;
@property (nonatomic, assign) NSInteger remaining;
@property (nonatomic, retain) NSString *verb;
@property (nonatomic, retain) NSString *regex;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, retain) NSDate *resetTime;
@property (nonatomic, retain) NSString *uri;

+ (RateLimit *)fromJSON:(NSDictionary *)dict;

@end
