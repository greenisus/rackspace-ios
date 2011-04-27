//
//  GetContainersRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetContainersRequest.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "AccountManager.h"
#import "GetCDNContainersRequest.h"


@implementation GetContainersRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetContainersRequest *request = [[[GetContainersRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	return request;
}

+ (id)filesRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.filesURL, path, now]];
    return [GetContainersRequest request:account method:method url:url];
}

+ (GetContainersRequest *)request:(OpenStackAccount *)account {
    GetContainersRequest *request = [GetContainersRequest filesRequest:account method:@"GET" path:@""];
    request.account = account;
    return request;
}

- (void)requestFinished {
    
    if ([self isSuccess]) {
        self.account.containers = [self containers];
        self.account.containerCount = [self.account.containers count];
        self.account.sortedContainers = nil;
        [self.account persist];
        [self.account.manager notify:@"getContainersSucceeded" request:self object:self.account];
        
        GetCDNContainersRequest *cdnRequest = [GetCDNContainersRequest request:self.account];
        [cdnRequest startAsynchronous];

    } else {
        [self.account.manager notify:@"getContainersFailed" request:self object:self.account];
    }
    
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    [self.account.manager notify:@"getContainersFailed" request:self object:self.account];
    [super failWithError:theError];
}


@end
