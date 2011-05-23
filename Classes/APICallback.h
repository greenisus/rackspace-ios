//
//  APICallback.h
//  OpenStack
//
//  Created by Mike Mayo on 03/23/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"

typedef void (^APIResponseBlock)(OpenStackRequest *request);

@class OpenStackAccount, OpenStackRequest;

@interface APICallback : NSObject {
    NSString *uuid;
    NSURL *url;
    NSString *verb;
    OpenStackAccount *account;
    OpenStackRequest *request;
    id successObserver;
    id failureObserver;
}

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *verb;
@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) OpenStackRequest *request;

- (id)initWithAccount:(OpenStackAccount *)account url:(NSURL *)url;
- (id)initWithAccount:(OpenStackAccount *)account url:(NSURL *)url verb:(NSString *)verb;
- (id)initWithAccount:(OpenStackAccount *)account request:(OpenStackRequest *)request;
- (void)success:(APIResponseBlock)successBlock failure:(APIResponseBlock)failureBlock;

@end
