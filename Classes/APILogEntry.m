//
//  APILogEntry.m
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "APILogEntry.h"
#import "OpenStackRequest.h"


@implementation APILogEntry

@synthesize requestMethod, requestBody, requestHeaders, responseStatusCode, responseHeaders, 
            responseBody, requestDate, responseStatusMessage, url;

- (id)initWithRequest:(OpenStackRequest *)request {
    if (self = [super init]) {
        
        if ([request requestMethod] != nil) {
            requestMethod = [[NSString alloc] initWithString:[request requestMethod]];
        }
        
        requestBody = [[NSString alloc] initWithData:request.postBody encoding:NSASCIIStringEncoding];
        requestHeaders = [[NSDictionary alloc] initWithDictionary:request.requestHeaders];
        responseStatusCode = [request responseStatusCode];
        responseHeaders = [[NSDictionary alloc] initWithDictionary:request.responseHeaders];
        
        if ([request responseString] != nil) {
            responseBody = [[NSString alloc] initWithString:[request responseString]];
        }
        
        requestDate = [[NSDate alloc] init];
        
        if ([request responseStatusMessage] != nil) {
            responseStatusMessage = [[NSString alloc] initWithString:[request responseStatusMessage]];
        }
        
        url = [request.url retain];
    }
    return self;
}

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:requestMethod forKey:@"requestMethod"];
    [coder encodeObject:requestBody forKey:@"requestBody"];
    [coder encodeObject:requestHeaders forKey:@"requestHeaders"];
    [coder encodeInt:responseStatusCode forKey:@"responseStatusCode"];
    [coder encodeObject:responseHeaders forKey:@"responseHeaders"];
    [coder encodeObject:responseBody forKey:@"responseBody"];
    [coder encodeObject:requestDate forKey:@"requestDate"];
    [coder encodeObject:responseStatusMessage forKey:@"responseStatusMessage"];
    [coder encodeObject:url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        requestMethod = [[coder decodeObjectForKey:@"requestMethod"] retain];
        requestBody = [[coder decodeObjectForKey:@"requestBody"] retain];
        requestHeaders = [[coder decodeObjectForKey:@"requestHeaders"] retain];
        responseStatusCode = [coder decodeIntForKey:@"responseStatusCode"];
        responseHeaders = [[coder decodeObjectForKey:@"responseHeaders"] retain];
        responseBody = [[coder decodeObjectForKey:@"responseBody"] retain];
        requestDate = [[coder decodeObjectForKey:@"requestDate"] retain];
        responseStatusMessage = [[coder decodeObjectForKey:@"responseStatusMessage"] retain];
        url = [[coder decodeObjectForKey:@"url"] retain];
    }
    return self;
}

- (NSString *)requestDescription {
    NSString *description = @"curl -verbose -X ";
    
    description = [description stringByAppendingString:requestMethod];
    
    NSArray *keys = [requestHeaders allKeys];
    for (int i = 0; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [requestHeaders objectForKey:key];

        // protect authentication info from being exposed
        /**/
        if ([key isEqualToString:@"X-Auth-Key"] || [key isEqualToString:@"X-Auth-Token"]) {
            value = @"<secret>";
        }
        /**/
        description = [description stringByAppendingString:[NSString stringWithFormat:@" -H \"%@: %@\"", key, value]];
    }

    if (requestBody && ![@"" isEqualToString:requestBody]) {
        description = [description stringByAppendingString:[NSString stringWithFormat:@" -d \"%@\"", requestBody]];
    }
    
    description = [description stringByAppendingString:[NSString stringWithFormat:@" %@", url]];
    
    return description;
}

- (NSString *)responseDescription {
    NSString *description = [NSString stringWithFormat:@"%@\n", responseStatusMessage];
    
    if (responseStatusCode == 0) {
        description = @"No response";
    } else {
        NSArray *keys = [responseHeaders allKeys];
        for (int i = 0; i < [keys count]; i++) {
            NSString *key = [keys objectAtIndex:i];
            NSString *value = [responseHeaders objectForKey:key];
            
            // protect authentication info from being exposed
            if ([key isEqualToString:@"X-Auth-Key"] || [key isEqualToString:@"X-Auth-Token"] || [key isEqualToString:@"X-Storage-Token"]) {
                value = @"<secret>";
            }
            description = [description stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", key, value]];
        }
        
        if (responseBody && ![@"" isEqualToString:responseBody]) {
            description = [description stringByAppendingString:[NSString stringWithFormat:@"\n%@", responseBody]];
        }
    }
    
    return description;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [requestMethod release];
    [requestBody release];
    [requestHeaders release];
    [responseHeaders release];
    [responseBody release];
    [requestDate release];
    [responseStatusMessage release];
    [url release];
    [super dealloc];
}

@end
