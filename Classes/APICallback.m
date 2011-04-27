//
//  APICallback.h
//  OpenStack
//
//  Created by Mike Mayo on 03/23/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "APICallback.h"


@implementation APICallback

@synthesize uuid, url, verb, account, request;

+ (NSString *)stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

- (id)initWithAccount:(OpenStackAccount *)anAccount url:(NSURL *)targetURL {
    if ((self = [super init])) {
        self.uuid = [APICallback stringWithUUID];
        self.url = targetURL;
        self.verb = @"GET";
        self.account = anAccount;
    }
    return self;
}

- (id)initWithAccount:(OpenStackAccount *)anAccount url:(NSURL *)targetURL verb:(NSString *)requestVerb {
    if ((self = [super init])) {
        self.uuid = [APICallback stringWithUUID];
        self.url = targetURL;
        self.verb = requestVerb;
        self.account = anAccount;
    }
    return self;
}

- (id)initWithAccount:(OpenStackAccount *)anAccount request:(OpenStackRequest *)openStackRequest {
    if ((self = [super init])) {
        self.uuid = [APICallback stringWithUUID];
        self.url = openStackRequest.url;
        self.verb = openStackRequest.requestMethod;
        self.account = anAccount;
        self.request = openStackRequest;
    }
    return self;
}

- (void)success:(APIResponseBlock)successBlock failure:(APIResponseBlock)failureBlock {

    NSString *successName = [NSString stringWithFormat:@"SUCCESS %@ %@%@", self.verb, [self.url description], (self.request ? [NSString stringWithFormat:@" %@", self.uuid] : @"")];
    NSLog(@"registering success: %@", successName);
    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:successName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification)
    {
        successBlock([notification.userInfo objectForKey:@"response"]);
        if (self.request) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
        }
    }];
    
    NSString *failureName = [NSString stringWithFormat:@"FAILURE %@ %@%@", self.verb, [self.url description], (self.request ? [NSString stringWithFormat:@" %@", self.uuid] : @"")];
    NSLog(@"registering failure: %@", failureName);
    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:failureName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification)
    {
        failureBlock([notification.userInfo objectForKey:@"response"]);
        if (self.request) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
        }
    }];    
}

- (void)dealloc {
    [uuid release];
    [url release];
    [verb release];
    [account release];
    [request release];
    [super dealloc];
}

@end
