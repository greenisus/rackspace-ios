//
//  GetObjectsRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GetObjectsRequest.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "StorageObject.h"
#import "AccountManager.h"
#import "Folder.h"


@implementation GetObjectsRequest

@synthesize container;

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	GetObjectsRequest *request = [[[GetObjectsRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
	return request;
}

+ (id)filesRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.filesURL, path, now]];
    return [GetObjectsRequest request:account method:method url:url];
}

+ (GetObjectsRequest *)request:(OpenStackAccount *)account container:(Container *)container {
    GetObjectsRequest *request = [GetObjectsRequest filesRequest:account method:@"GET" path:[[NSString stringWithFormat:@"/%@", container.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
    request.account = account;
    request.container = container;
    return request;
}

- (void)requestFinished {
    if ([self isSuccess]) {        
        Container *aContainer = self.container;  //[self.userInfo objectForKey:@"container"];
        NSMutableDictionary *objects = [self objects];
        aContainer.rootFolder = [Folder folder];
        aContainer.rootFolder.objects = objects;
        [self.account persist];
        
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsSucceeded" object:self.container userInfo:[NSDictionary dictionaryWithObject:aContainer forKey:@"container"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.container userInfo:[NSDictionary dictionaryWithObject:self forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.container userInfo:[NSDictionary dictionaryWithObject:self forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [super failWithError:theError];
}

- (void)dealloc {
    [container release];
    [super dealloc];
}

@end
