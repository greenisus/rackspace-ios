//
//  GetCDNContainersRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetCDNContainersRequest.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Container.h"


@implementation GetCDNContainersRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetCDNContainersRequest *request = [[[GetCDNContainersRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
    if ([account authToken]) {
        [request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    }
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	return request;
}

+ (id)cdnRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.cdnURL, path, now]];
    return [GetCDNContainersRequest request:account method:method url:url];
}

+ (GetCDNContainersRequest *)request:(OpenStackAccount *)account {
    GetCDNContainersRequest *request = [GetCDNContainersRequest cdnRequest:account method:@"GET" path:@""];
    request.account = account;
    return request;
}

- (void)requestFinished {
    if ([self isSuccess]) {        
        NSDictionary *cdnContainers = [self containers];
        
        for (NSString *key in cdnContainers) {
            
            Container *cdnContainer = [cdnContainers objectForKey:key];
            Container *container = [self.account.containers objectForKey:key];
            if (cdnContainer && container) {
                container.cdnEnabled = cdnContainer.cdnEnabled;
                container.ttl = cdnContainer.ttl;
                container.cdnURL = cdnContainer.cdnURL;
                container.referrerACL = cdnContainer.referrerACL;
                container.useragentACL = cdnContainer.useragentACL;
                container.logRetention = cdnContainer.logRetention;
                container.hasEverBeenCDNEnabled = YES;
            }
        }
        
        [self.account persist];
        [self.account.manager notify:@"getCDNContainersSucceeded" request:self object:self.account];
    } else {
        [self.account.manager notify:@"getCDNContainersFailed" request:self object:self.account];
    }
    
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    [self.account.manager notify:@"getCDNContainersFailed" request:self object:self.account];
    [super failWithError:theError];
}

@end
