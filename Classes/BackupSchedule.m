//
//  BackupSchedule.m
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "BackupSchedule.h"
#import "NSObject+NSCoding.h"


@implementation BackupSchedule

@synthesize enabled, weekly, daily;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeBool:enabled forKey:@"enabled"];
    [coder encodeObject:weekly forKey:@"weekly"];
    [coder encodeObject:daily forKey:@"daily"];
     */
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        enabled = [coder decodeBoolForKey:@"enabled"];
        weekly = [[coder decodeObjectForKey:@"weekly"] retain];
        daily = [[coder decodeObjectForKey:@"daily"] retain];
         */
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (BackupSchedule *)fromJSON:(NSDictionary *)dict {
    BackupSchedule *backupSchedule = [[BackupSchedule alloc] init];
    backupSchedule.enabled = [[dict objectForKey:@"enabled"] boolValue];
    backupSchedule.weekly = [dict objectForKey:@"weekly"];
    backupSchedule.daily = [dict objectForKey:@"daily"];
    return backupSchedule;
}

#pragma mark -
#pragma mark Display

+ (NSDictionary *)weeklyOptionsDict {
    NSArray *weeklyOptions = [BackupSchedule weeklyOptions];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:8];
    for (NSString *option in weeklyOptions) {
        [dict setObject:[BackupSchedule humanizedWeeklyForString:option] forKey:option];
    }
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:dict];
    [dict release];     
    return result;
}

+ (NSDictionary *)dailyOptionsDict {
    NSArray *dailyOptions = [BackupSchedule dailyOptions];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:13];
    for (NSString *option in dailyOptions) {
        [dict setObject:[BackupSchedule humanizedDailyForString:option] forKey:option];
    }
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:dict];
    [dict release];     
    return result;
}

+ (NSArray *)weeklyOptions {
    return [NSArray arrayWithObjects:@"DISABLED", @"MONDAY", @"TUESDAY", @"WEDNESDAY", @"THURSDAY", @"FRIDAY", @"SATURDAY", @"SUNDAY", nil];
}

+ (NSArray *)dailyOptions {
    NSArray *timeRanges = [NSArray arrayWithObjects:@"H_0000_0200", @"H_0200_0400", @"H_0400_0600", @"H_0600_0800", @"H_0800_1000", @"H_1000_1200", @"H_1200_1400", @"H_1400_1600", @"H_1600_1800", @"H_1800_2000", @"H_2000_2200", @"H_2200_0000", nil];
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger gmtOffset = (([tz secondsFromGMT] / 3600) / 2);    
    if (gmtOffset < 0) {
        gmtOffset = [timeRanges count] + gmtOffset;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:12];
    for (int i = gmtOffset; i < [timeRanges count]; i++) {
        [arr addObject:[timeRanges objectAtIndex:i]];
    }
    for (int i = 0; i < gmtOffset; i++) {
        [arr addObject:[timeRanges objectAtIndex:i]];
    }
         
    [arr insertObject:@"DISABLED" atIndex:0];
    
    NSArray *result = [NSArray arrayWithArray:arr];
    [arr release];
    return result;
}

+ (NSString *)humanizedWeeklyForString:(NSString *)weeklyString {
    
    if ([weeklyString isEqualToString:@"DISABLED"]) {
        return @"Disabled";
    } else if ([weeklyString isEqualToString:@"MONDAY"]) {
        return @"Every Monday";
    } else if ([weeklyString isEqualToString:@"TUESDAY"]) {
        return @"Every Tuesday";
    } else if ([weeklyString isEqualToString:@"WEDNESDAY"]) {
        return @"Every Wednesday";
    } else if ([weeklyString isEqualToString:@"THURSDAY"]) {
        return @"Every Thursday";
    } else if ([weeklyString isEqualToString:@"FRIDAY"]) {
        return @"Every Friday";
    } else if ([weeklyString isEqualToString:@"SATURDAY"]) {
        return @"Every Saturday";
    } else if ([weeklyString isEqualToString:@"SUNDAY"]) {
        return @"Every Sunday";
    } else {
        return weeklyString;
    } 
}

+ (NSString *)humanizedDailyForString:(NSString *)timeRange {

    if ([timeRange isEqualToString:@"DISABLED"]) {
        return @"Disabled";
    } else {      
        NSTimeZone *tz = [NSTimeZone systemTimeZone];
        NSArray *components = [timeRange componentsSeparatedByString:@"_"];

        NSInteger gmtOffset = ([tz secondsFromGMT] / 3600) * 100;
        NSInteger fromInt = [[components objectAtIndex:1] intValue] + gmtOffset;
        if (fromInt < 0) {
            fromInt += 2400;
        }
        
        NSString *from = @"";
        if (fromInt >= 1200) {
            from = [NSString stringWithFormat:@"%i:00 PM", (fromInt - 1200) / 100];
        } else if (fromInt == 0) {
            from = @"12:00 AM";
        } else {
            from = [NSString stringWithFormat:@"%i:00 AM", fromInt / 100];
        }
        
        if ([from isEqualToString:@"0:00 PM"]) {
            from = @"12:00 PM";
        } else if ([from isEqualToString:@"0:00 AM"]) {
            from = @"12:00 AM";
        }
        
        NSInteger toInt = [[components objectAtIndex:2] intValue] + gmtOffset;
        if (toInt < 0) {
            toInt += 2400;
        }
        NSString *to = @"";
        if (toInt >= 1200) {
            to = [NSString stringWithFormat:@"%i:00 PM", (toInt - 1200) / 100];
        } else if (toInt == 0) {
            to = @"12:00 AM";
        } else {
            to = [NSString stringWithFormat:@"%i:00 AM", toInt / 100];
        }

        if ([to isEqualToString:@"0:00 PM"]) {
            to = @"12:00 PM";
        } else if ([to isEqualToString:@"0:00 AM"]) {
            to = @"12:00 AM";
        }
        
        return [NSString stringWithFormat:@"%@ - %@ %@", from, to, [tz abbreviation]];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [weekly release];
    [daily release];
    [super dealloc];
}

@end
