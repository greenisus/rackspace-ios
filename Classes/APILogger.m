//
//  APILogger.m
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "APILogger.h"
#import "OpenStackRequest.h"
#import "APILogEntry.h"
#import "Archiver.h"

#define kMaxLogEntries 1000

static NSArray *loggerEntries = nil;

@implementation APILogger

+ (void)initialize {
    // TODO: restore
    loggerEntries = [[NSArray alloc] init];
    /*
    loggerEntries = [Archiver retrieve:@"loggerEntries"];
    if (loggerEntries == nil) {
        loggerEntries = [[NSArray alloc] init];
        [Archiver persist:loggerEntries key:@"loggerEntries"];
    }
     */
}

+ (NSArray *)loggerEntries {
    if (loggerEntries == nil) {
        loggerEntries = [Archiver retrieve:@"loggerEntries"];
    }
    return loggerEntries;
}

+ (void)log:(OpenStackRequest *)request {

    return; // disabling request logging for performance
    
    APILogEntry *entry = [[APILogEntry alloc] initWithRequest:request];
    
    NSMutableArray *entries = [NSMutableArray arrayWithArray:[APILogger loggerEntries]];
    [entries insertObject:entry atIndex:0];
    [entry release];
    
    while ([entries count] > kMaxLogEntries) {
        [entries removeLastObject];
    }
    
    // not checking for success since it's just logging
    [Archiver persist:[NSArray arrayWithArray:entries] key:@"loggerEntries"];
    
    loggerEntries = nil;
}

+ (BOOL)eraseAllLogs {
    loggerEntries = nil;
    return [Archiver delete:@"loggerEntries"];
}

@end
