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

@property (nonatomic, retain) NSString *requestMethod;
@property (nonatomic, retain) NSString *requestBody;
@property (nonatomic, retain) NSDictionary *requestHeaders;
@property (assign) NSInteger responseStatusCode;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSString *responseBody;
@property (nonatomic, retain) NSDate *requestDate;
@property (nonatomic, retain) NSString *responseStatusMessage;
@property (nonatomic, retain) NSURL *url;

- (id)initWithRequest:(OpenStackRequest *)request;
- (NSString *)requestDescription;
- (NSString *)responseDescription;

@end
