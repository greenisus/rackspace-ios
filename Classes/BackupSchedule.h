//
//  BackupSchedule.h
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>


@interface BackupSchedule : NSObject <NSCoding> {
    BOOL enabled;
    NSString *weekly;
    NSString *daily;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, retain) NSString *weekly;
@property (nonatomic, retain) NSString *daily;

+ (NSArray *)weeklyOptions;
+ (NSArray *)dailyOptions;
+ (NSDictionary *)weeklyOptionsDict;
+ (NSDictionary *)dailyOptionsDict;
+ (NSString *)humanizedWeeklyForString:(NSString *)weeklyString;
+ (NSString *)humanizedDailyForString:(NSString *)timeRange;

+ (BackupSchedule *)fromJSON:(NSDictionary *)dict;

@end
