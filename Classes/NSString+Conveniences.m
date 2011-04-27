//
//  NSString+Conveniences.m
//  OpenStack
//
//  Created by Mike Mayo on 10/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "NSString+Conveniences.h"


@implementation NSString (Conveniences)

- (BOOL)isURL {
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"];
}

@end
