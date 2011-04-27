//
//  ComputeModel.h
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

// superclass for OpenStack Compute models with common parsing and utility methods
@interface ComputeModel : NSObject <NSCoding> {
    NSInteger identifier; // i'd call it id, but Objective-C won't let me :(
    NSString *name;
}

@property (assign) NSInteger identifier;
@property (retain) NSString *name;

// parses the stuff common to all models for you
- (id)initWithJSONDict:(NSDictionary *)dict;

- (NSInteger)intForKey:(NSString *)key inDict:(NSDictionary *)dict;
- (NSDate *)dateForKey:(NSString *)key inDict:(NSDictionary *)dict;

+ (NSDate *)dateFromString:(NSString *)dateString;
- (NSDate *)dateFromString:(NSString *)dateString;

- (NSComparisonResult)compare:(ComputeModel *)aComputeModel;

@end
