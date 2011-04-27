//
//  NSObject+Conveniences.m
//
//  Created by Mike Mayo on 8/3/10.
//

#import "NSObject+Conveniences.h"

@implementation NSObject (Conveniences)

#pragma mark -
#pragma mark Resize UIImage

// Pass in the same size for width and height to resize the image to fit within that square and maintain its aspect ratio.
// Pass in a width and a zero height to resize the image to fit that width and maintain its aspect ratio.
// Pass in a height and a zero width to resize the image to fit that height and maintain its aspect ratio.
// Pass in a width and height to resize the image to that exact size ignoring the aspect ratio.
// Under iOS 4.0 or greater the new image retains the 'scale' of the original image.

+ (NSString *)stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

+ (NSString *)pluralizedStringForArray:(NSArray *)array noun:(NSString *)noun {
    if ([array count] == 1) {
        return [NSString stringWithFormat:@"1 %@", noun];
    } else {
        return [NSString stringWithFormat:@"%i %@s", [array count], noun];
    }
}

+ (NSString *)pluralizedStringForDictionary:(NSDictionary *)dict noun:(NSString *)noun {
    if ([dict count] == 1) {
        return [NSString stringWithFormat:@"1 %@", noun];
    } else {
        return [NSString stringWithFormat:@"%i %@s", [dict count], noun];
    }
}

+ (UIImage *)resizeImage:(UIImage *)image toWidth:(int)width andHeight:(int)height {
    int newWidth = width;
    int newHeight = height;
    if (width == height || width == 0 || height == 0) {
        int w = image.size.width;
        int h = image.size.height;
        
        float scale = 0;
        if (width == height) {
            scale = fmin((float)width / (float)w, (float)height / (float)h);
        } else if (width == 0) {
            scale = (float)height / (float)h;
        } else if (height == 0) {
            scale = (float)width / (float)h;
        }
        
        newWidth = floor(scale * w + 0.5);
        newHeight = floor(scale * h + 0.5);
    }
    
    CGRect area = CGRectMake(0, 0, newWidth, newHeight);
    CGSize size = area.size;
    if ([image respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    [image drawInRect:area];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [newImage retain];    
    return newImage;
}

+ (BOOL)parseBool:(NSNumber *)number {
    BOOL result = NO;
    if (number != (NSNumber *)[NSNull null]) {
        result = [number boolValue];
    }
    return result;
}

+ (BOOL)stringIsEmpty:(NSString *)string {
    return !string || (string == (NSString *)[NSNull null]) || [@"" isEqualToString:string];
}

+ (NSString *)dateToLongString:(NSDate *)date {
    if (!date) {
        return nil;
    } else {
        NSString *result = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        result = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], [[NSTimeZone systemTimeZone] abbreviation]];
        [dateFormatter release];

        return result;
    }
}

+ (NSString *)dateToString:(NSDate *)date {
    if (!date) {
        return nil;
    } else {
        NSString *result = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        result = [dateFormatter stringFromDate:date];
        [dateFormatter release];
        return result;
    }
}

+ (NSString *)dateToStringWithTime:(NSDate *)date {
    if (!date) {
        return nil;
    } else {
        NSString *result = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        //[dateFormatter setTimeStyle:NSDateFormatterLongStyle];

        result = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], [[NSTimeZone systemTimeZone] abbreviation]];
        [dateFormatter release];
        return result;
    }
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    if ([[self class] stringIsEmpty:dateString]) {
        return nil;
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
        // example: 1980-01-26T06:00:00Z
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss'Z'"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        [dateFormatter release];
        
        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
        
        NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
        NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
        NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
        
        NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:date] autorelease];
        
        return destinationDate;
    }
}

- (NSString *)timeUntilDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date] toDate:date options:0];
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    [gregorian release];

    if (days < 0 || hours < 0 || minutes < 0 || seconds < 0) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%02i:%02i:%02i:%02i", days, hours, minutes, seconds];
    }
}

- (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
        
    }    
    return html;    
}

/*
- (NSString *)flattenHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        //remove html tag
        [theScanner scanUpToString:@"<" intoString:NULL];
        [theScanner scanString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", text] withString:@""];
    }
    return html;
}
*/
@end

