//
//  ComputeModel.m
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"
#import "NSObject+NSCoding.h"


@implementation ComputeModel

@synthesize identifier, name;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeInt:identifier forKey:@"id"];
    [coder encodeObject:name forKey:@"name"];
     */
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        identifier = [coder decodeIntForKey:@"id"];
        name = [[coder decodeObjectForKey:@"name"] retain];
         */
    }
    return self;
}

#pragma mark -
#pragma mark JSON Parsing

- (id)initWithJSONDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.identifier = [self intForKey:@"id" inDict:dict];
        self.name = [dict objectForKey:@"name"];
    }
    return self;
}

- (NSInteger)intForKey:(NSString *)key inDict:(NSDictionary *)dict {
    NSInteger result = 0;
    if ([dict objectForKey:key] != [NSNull null]) {
        result = [((NSNumber *)[dict objectForKey:key]) intValue];
    }
    return result;
}

- (NSDate *)dateForKey:(NSString *)key inDict:(NSDictionary *)dict {
    NSDate *date = nil;
    if ([dict objectForKey:key] != [NSNull null]) {
        date = [self dateFromString:[dict objectForKey:key]];
    }
    return date;
}

#pragma mark -
#pragma mark Date Parser

+ (NSDate *)dateFromString:(NSString *)dateString {
    return nil; // temporarily removing date parsing for performance
    
    /*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	// example: 2009-11-04T19:46:20.192723
    // 2010-01-26T12:07:32-06:00

    // this is nasty, but -06:00 is not a valid timezone format.  converting to -0600 style
    dateString = [NSString stringWithFormat:@"%@%@", [dateString substringToIndex:22], [dateString substringFromIndex:23]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ssZ"];

	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	
	return date;
     */
}

- (NSDate *)dateFromString:(NSString *)dateString {
	return [[self class] dateFromString:dateString];
}

#pragma mark Comparison

- (NSComparisonResult)compare:(ComputeModel *)aComputeModel {
    return [self.name caseInsensitiveCompare:aComputeModel.name];
}

- (NSString *)description {
    if ([[self class] respondsToSelector:@selector(toJSON:)]) {
        return [[self class] performSelector:@selector(toJSON:) withObject:self];
    } else {
        return [super description];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [name release];
    [super dealloc];
}

@end
