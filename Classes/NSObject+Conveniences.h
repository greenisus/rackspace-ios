//
//  NSObject+Conveniences.h
//
//  Created by Mike Mayo on 8/3/10.
//

#import <Foundation/Foundation.h>


@interface NSObject (Conveniences)

+ (NSString*) stringWithUUID;
+ (NSString *)pluralizedStringForArray:(NSArray *)array noun:(NSString *)noun;
+ (NSString *)pluralizedStringForDictionary:(NSDictionary *)dict noun:(NSString *)noun;
+ (UIImage *)resizeImage:(UIImage *)image toWidth:(int)width andHeight:(int)height;
+ (BOOL)parseBool:(NSNumber *)number;
+ (BOOL)stringIsEmpty:(NSString *)string;
+ (NSString *)dateToString:(NSDate *)date;
+ (NSString *)dateToLongString:(NSDate *)date;
+ (NSString *)dateToStringWithTime:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)dateString;
- (NSString *)timeUntilDate:(NSDate *)date;
- (NSString *)flattenHTML:(NSString *)html;

@end
