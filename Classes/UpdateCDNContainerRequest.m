//
//  UpdateCDNContainerRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "UpdateCDNContainerRequest.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "AccountManager.h"


@implementation UpdateCDNContainerRequest

@synthesize container;

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	UpdateCDNContainerRequest *request = [[[UpdateCDNContainerRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	return request;
}

+ (id)cdnRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.cdnURL, path, now]];
    return [UpdateCDNContainerRequest request:account method:method url:url];
}

+ (UpdateCDNContainerRequest *)request:(OpenStackAccount *)account container:(Container *)container {
    NSString *method = @"PUT";
    if (container.hasEverBeenCDNEnabled) {
        method = @"POST";
    }
    UpdateCDNContainerRequest *request = [UpdateCDNContainerRequest cdnRequest:account method:method path:[[NSString stringWithFormat:@"/%@", container.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request.account = account;
    request.container = container;
    
    if (container.referrerACL) {
        [request.requestHeaders setObject:container.referrerACL forKey:@"X-Referrer-ACL"];
    }
    
    if (container.useragentACL) {
        [request.requestHeaders setObject:container.useragentACL forKey:@"X-User-Agent-ACL"];
    }
    
    [request.requestHeaders setObject:[NSString stringWithFormat:@"%i", container.ttl] forKey:@"X-TTL"];
    [request.requestHeaders setObject:container.logRetention ? @"True" : @"False" forKey:@"X-Log-Retention"];
    
    if (container.hasEverBeenCDNEnabled) {
        [request.requestHeaders setObject:container.cdnEnabled ? @"True" : @"False" forKey:@"X-CDN-Enabled"];
    }
    
    return request;
}

- (void)requestFinished {  
    
    NSLog(@"update CDN container response: %i", [self responseStatusCode]);
    
    if ([self isSuccess]) {
        self.container.cdnURL = [self.responseHeaders objectForKey:@"X-Cdn-Uri"];
        self.container.hasEverBeenCDNEnabled = YES;
        
        
        [self.account persist];
        [self.account.manager notify:@"updateCDNContainerSucceeded" request:self object:self.container];
    } else {
        [self.account.manager notify:@"updateCDNContainerFailed" request:self object:self.container];
    }
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    [self.account.manager notify:@"updateCDNContainerFailed" request:self object:self.container];
    [super failWithError:theError];
}

- (void)dealloc {
    [container release];
    [super dealloc];
}

@end
