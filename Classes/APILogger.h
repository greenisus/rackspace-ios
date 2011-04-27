//
//  APILogger.h
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class OpenStackRequest;

@interface APILogger : NSObject {

}

+ (void)log:(OpenStackRequest *)request;
+ (NSArray *)loggerEntries;
+ (BOOL)eraseAllLogs;

@end
