//
//  APILogEntry.h
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class OpenStackRequest;

@interface APILogEntry : NSObject <NSCoding> {
    NSString *requestMethod;
    NSString *requestBody;
    NSDictionary *requestHeaders;
    NSInteger responseStatusCode;
    NSDictionary *responseHeaders;
    NSString *responseBody;
    NSDate *requestDate;
    NSString *responseStatusMessage;
    NSURL *url;
}

@property (retain) NSString *requestMethod;
@property (retain) NSString *requestBody;
@property (retain) NSDictionary *requestHeaders;
@property (assign) NSInteger responseStatusCode;
@property (retain) NSDictionary *responseHeaders;
@property (retain) NSString *responseBody;
@property (retain) NSDate *requestDate;
@property (retain) NSString *responseStatusMessage;
@property (retain) NSURL *url;

- (id)initWithRequest:(OpenStackRequest *)request;
- (NSString *)requestDescription;
- (NSString *)responseDescription;

@end
