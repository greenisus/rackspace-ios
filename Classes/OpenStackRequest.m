//
//  OpenStackRequest.m
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"
#import "Provider.h"
#import "OpenStackAccount.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "APILogger.h"
#import "JSON.h"
#import "RateLimit.h"
#import "Container.h"
#import "StorageObject.h"
#import "Folder.h"
#import "BackupSchedule.h"
#import "AccountManager.h"
#import "GetFlavorsRequest.h"
#import "APICallback.h"
#import "APILogEntry.h"


static NSRecursiveLock *accessDetailsLock = nil;

@implementation OpenStackRequest

@synthesize account, callback, retriedCount;

- (BOOL)isSuccess {
	return (200 <= [self responseStatusCode]) && ([self responseStatusCode] <= 299);
}

- (void)notify:(NSString *)name {
    NSLog(@"notify: %@", name);
    NSDictionary *callbackUserInfo = [NSDictionary dictionaryWithObject:self forKey:@"response"];
    NSNotification *notification = [NSNotification notificationWithName:name object:nil userInfo:callbackUserInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)notify {
//    [self notify:[NSString stringWithFormat:@"%@ %@ %@", [self isSuccess] ? @"SUCCESS" : @"FAILURE", self.requestMethod, [self.url description]]];
//    [self notify:[NSString stringWithFormat:@"%@ %@ %@ %@", [self isSuccess] ? @"SUCCESS" : @"FAILURE", self.requestMethod, [self.url description], self.callback.uuid]];
    NSString *observeName = [NSString stringWithFormat:@"%@ %@ %@", [self isSuccess] ? @"SUCCESS" : @"FAILURE", self.requestMethod, [self.url description]];
    NSString *callbackName = [NSString stringWithFormat:@"%@ %@ %@ %@", [self isSuccess] ? @"SUCCESS" : @"FAILURE", self.requestMethod, [self.url description], self.callback.uuid];
    
    NSLog(@"notify: %@", observeName);
    NSLog(@"notify: %@", callbackName);
    
    NSDictionary *callbackUserInfo = [NSDictionary dictionaryWithObject:self forKey:@"response"];

    NSNotification *observeNotification = [NSNotification notificationWithName:observeName object:nil userInfo:callbackUserInfo];
    [[NSNotificationCenter defaultCenter] postNotification:observeNotification];

    NSNotification *callbackNotification = [NSNotification notificationWithName:callbackName object:nil userInfo:callbackUserInfo];
    [[NSNotificationCenter defaultCenter] postNotification:callbackNotification];
    
}

- (NSString *)responseString {
    if (retried) {
        return [retriedRequest responseString];
    } else {
        return [super responseString];
    }
}

- (NSData *)responseData {
    if (retried) {
        return [retriedRequest responseData];
    } else {
        return [super responseData];
    }
}

- (NSDictionary *)responseHeaders {
    if (retried) {
        return [retriedRequest responseHeaders];
    } else {
        return [super responseHeaders];
    }
}

- (int)responseStatusCode {
    if (retried) {
        return [retriedRequest responseStatusCode];
    } else {
        return [super responseStatusCode];
    }
}

- (NSString *)responseStatusMessage {
    if (retried) {
        return [retriedRequest responseStatusMessage];
    } else {
        return [super responseStatusMessage];
    }
}

- (void)setCompletionBlock:(ASIBasicBlock)aCompletionBlock {
    [super setCompletionBlock:aCompletionBlock];
    [backupCompletionBlock release];
    backupCompletionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(ASIBasicBlock)aFailedBlock {
    [super setFailedBlock:aFailedBlock];
    [backupFailureBlock release];
    backupFailureBlock = [aFailedBlock copy];
}

+ (RateLimit *)limitForPath:(NSString *)path verb:(NSString *)verb account:(OpenStackAccount *)anAccount {
    
    // find the lowest requests remaining of all the limits

    RateLimit *lowestLimit = nil;
    
    for (RateLimit *limit in anAccount.rateLimits) {
        if ([limit.verb isEqualToString:verb]) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:limit.regex options:NSRegularExpressionCaseInsensitive error:nil];
            NSInteger matches = [regex numberOfMatchesInString:path options:0 range:NSMakeRange(0, [path length])];
            
            if (matches > 0) {
                if (lowestLimit) {
                    if (limit.remaining < lowestLimit.remaining) {
                        lowestLimit = limit;
                    }
                } else {
                    lowestLimit = limit;
                }
            }
        }
    }
    
    return lowestLimit;
}

#pragma mark -
#pragma mark Generic Constructors

+ (void)initialize {
	if (self == [OpenStackRequest class]) {
		accessDetailsLock = [[NSRecursiveLock alloc] init];
	}
}

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	OpenStackRequest *request = [[[OpenStackRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:60];
    request.retriedCount = 0;
	return request;
}

+ (id)serversRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?now=%@", account.serversURL, path, now]];
    return [OpenStackRequest request:account method:method url:url];
}

+ (id)filesRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.filesURL, path, now]];    
    return [OpenStackRequest request:account method:method url:url];
}

+ (id)cdnRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?format=json&now=%@", account.cdnURL, path, now]];
    return [OpenStackRequest request:account method:method url:url];
}

#pragma mark -
#pragma mark Auth Retry

- (void)authRetrySucceded:(OpenStackRequest *)retryRequest {
    
    if ([self isKindOfClass:[GetFlavorsRequest class]]) {
        NSLog(@"flavor request");
    }
    
    self.account.authToken = [[retryRequest responseHeaders] objectForKey:@"X-Auth-Token"];    
    [self.account persist];
    
    // TODO: make this work for GetServersRequest, etc
    
    // try the original request again!
    retried = YES;
    retriedRequest = [self copy];
	[retriedRequest addRequestHeader:@"X-Auth-Token" value:self.account.authToken];    
    
    if (backupCompletionBlock) {
        [retriedRequest setCompletionBlock:^{
            backupCompletionBlock();
        }];
    }
    if (backupFailureBlock) {
        [retriedRequest setFailedBlock:^{
            backupFailureBlock();
        }];
    }
    [retriedRequest startSynchronous];     
}

- (void)authRetryFailed:(OpenStackRequest *)retryRequest {
    // if it fails due to bad connection, try again?
    NSLog(@"auth retry failed with status %i", retryRequest.responseStatusCode);
    NSNotification *notification = [NSNotification notificationWithName:[self.account.manager notificationName:@"authRetryFailed" identifier:0] object:nil userInfo:[NSDictionary dictionaryWithObject:retryRequest forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark -
#pragma mark ASIHTTPRequest Overrides
// overriding to log API calls

- (void)requestFinished {
    //NSLog(@"request finished: %i %@", self.responseStatusCode, self.url);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loggingLevel = [defaults valueForKey:@"api_logging_level"];    
    if ([loggingLevel isEqualToString:@"all"] || ([loggingLevel isEqualToString:@"errors"] && ![self isSuccess])) {
        [APILogger log:self];
    }
    
    [super requestFinished];
}

- (void)failWithError:(NSError *)theError {
    NSLog(@"request failed: %i %@: %@", self.responseStatusCode, self.url, [theError description]);
    
    // if the response code is 401 and this isn't the auth request, we have
    // an expired auth token.  So we need to get a fresh auth token and try the request
    // again.
    if (responseStatusCode == 401 && ![url isEqual:account.provider.authEndpointURL]) {
        if (account) {
            //NSLog(@"Expired auth token for %@", url);
            //NSLog(@"Expired user: %@, %@", account, account.username);
            
            OpenStackRequest *retryRequest = [OpenStackRequest authenticationRequest:account];
            retryRequest.delegate = self;
            retryRequest.didFinishSelector = @selector(authRetrySucceded:);
            retryRequest.didFailSelector = @selector(authRetryFailed:);
            [retryRequest startSynchronous];
        }
    } else if (responseStatusCode == 503) {        
        NSNotification *notification = [NSNotification notificationWithName:@"serviceUnavailable" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];        
        [super failWithError:theError];
    } else if (responseStatusCode == 0 && [url host] && self.retriedCount < 10) {
        
        NSLog(@"Retrying from timeout for %@, host: %@", url, [url host]);
        retried = YES;
        retriedRequest = [self copy];
        retriedRequest.retriedCount = self.retriedCount + 1;
        if (backupCompletionBlock) {
            [retriedRequest setCompletionBlock:^{
                backupCompletionBlock();
            }];
        }
        if (backupFailureBlock) {
            [retriedRequest setFailedBlock:^{
                backupFailureBlock();
            }];
        }
        // delay a little to not get a string of timeouts all at once
        //[NSTimer scheduledTimerWithTimeInterval:0.25 target:retriedRequest selector:@selector(startSynchronous) userInfo:nil repeats:NO];
        /*
        APILogEntry *e = [[APILogEntry alloc] initWithRequest:retriedRequest];
        NSLog(@"%@", [e requestDescription]);
        */
        [retriedRequest startSynchronous];      
        //[retriedRequest startAsynchronous];
        
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *loggingLevel = [defaults valueForKey:@"api_logging_level"];    
        if ([loggingLevel isEqualToString:@"all"] || ([loggingLevel isEqualToString:@"errors"] && ![self isSuccess])) {
            [APILogger log:self];
        }
        [super failWithError:theError];
    }
}

#pragma mark -
#pragma mark Authentication

+ (OpenStackRequest *)authenticationRequest:(OpenStackAccount *)account {
 	//[accessDetailsLock lock];
	OpenStackRequest *request = [[[OpenStackRequest alloc] initWithURL:account.provider.authEndpointURL] autorelease];
    
    
    //request.didFinishSelector
    
    request.account = account;
    //NSLog(@"auth: %@ %@", account.username, account.apiKey);
	[request addRequestHeader:@"X-Auth-User" value:account.username];
	[request addRequestHeader:@"X-Auth-Key" value:account.apiKey];
    
    //NSLog(@"Authenticating to %@ with %@/%@", account.provider.authEndpointURL, account.username, account.apiKey);
    
	//[accessDetailsLock unlock];
	return request;
}

#pragma mark -
#pragma mark Rate Limits

+ (OpenStackRequest *)getLimitsRequest:(OpenStackAccount *)account {
    return [OpenStackRequest serversRequest:account method:@"GET" path:@"/limits"];
}

- (NSDictionary *)limits {
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"limits"];    
    [parser release];
    return jsonObjects;
}

- (NSArray *)rateLimits {
    NSArray *jsonObjects = [[self limits] objectForKey:@"rate"];
    NSMutableArray *rateLimits = [[NSMutableArray alloc] initWithCapacity:[jsonObjects count]];

    for (NSDictionary *dict in jsonObjects) {
        [rateLimits addObject:[RateLimit fromJSON:dict]];
    }

    NSArray *result = [NSArray arrayWithArray:rateLimits];
    
    [rateLimits release];
    return result;
}

#pragma mark Collections

+ (OpenStackRequest *)getServersRequest:(OpenStackAccount *)account {
    return [OpenStackRequest serversRequest:account method:@"GET" path:@"/servers/detail"];
}

- (NSDictionary *)servers {
    /* TODO: for all methods like this: set up servers to return autoreleased list of objects instead of retained NSMutableDictionary
     * Analyzer perceives this as a potential leak since it's not a method named "alloc" or "copy"
     */
    //NSLog(@"about to parse %@", [self responseString]);
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"servers"];
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Server *server = [Server fromJSON:dict];
        [objects setObject:server forKey:[NSNumber numberWithInt:server.identifier]];
    }
    
    [parser release];
    return objects;
}

+ (OpenStackRequest *)getServerRequest:(OpenStackAccount *)account serverId:(NSInteger)serverId {
    return [OpenStackRequest serversRequest:account method:@"GET" path:[NSString stringWithFormat:@"/servers/%i", serverId]];
}

+ (OpenStackRequest *)getImagesRequest:(OpenStackAccount *)account {
    return [OpenStackRequest serversRequest:account method:@"GET" path:@"/images/detail"];
}

- (NSDictionary *)images {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"images"];
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Image *image = [Image fromJSON:dict];
        [objects setObject:image forKey:[NSNumber numberWithInt:image.identifier]];
    }
    
    [parser release];
    return objects;
}

+ (OpenStackRequest *)getImageRequest:(OpenStackAccount *)account imageId:(NSInteger)imageId {
    return [OpenStackRequest serversRequest:account method:@"GET" path:[NSString stringWithFormat:@"/images/%i", imageId]];
}

- (Image *)image {
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dict = [[parser objectWithString:[self responseString]] objectForKey:@"image"];
    Image *image = [Image fromJSON:dict];
    [parser release];
    return image;
}


+ (OpenStackRequest *)getFlavorsRequest:(OpenStackAccount *)account {
    return [OpenStackRequest serversRequest:account method:@"GET" path:@"/flavors/detail"];
}

- (NSDictionary *)flavors {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"flavors"];
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]];

    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Flavor *flavor = [Flavor fromJSON:dict];
        [objects setObject:flavor forKey:[NSNumber numberWithInt:flavor.identifier]];
    }
    
    [parser release];
    return objects;
}

#pragma mark Server Actions

+ (OpenStackRequest *)softRebootServerRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = @"{ \"reboot\": { \"type\": \"SOFT\" } }";
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)softRebootServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}

+ (OpenStackRequest *)hardRebootServerRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = @"{ \"reboot\": { \"type\": \"HARD\" } }";
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)hardRebootServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}

+ (OpenStackRequest *)changeServerAdminPasswordRequest:(OpenStackAccount *)account server:(Server *)server password:(NSString *)password {
	NSString *body = [NSString stringWithFormat:@"{ \"server\": { \"adminPass\": \"%@\" } }", password];
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"PUT" path:[NSString stringWithFormat:@"/servers/%i", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)changeServerAdminPasswordLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i", server.identifier] verb:@"PUT" account:account];
}

+ (OpenStackRequest *)renameServerRequest:(OpenStackAccount *)account server:(Server *)server name:(NSString *)name {
	NSString *body = [NSString stringWithFormat:@"{ \"server\": { \"name\": \"%@\" } }", name];
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"PUT" path:[NSString stringWithFormat:@"/servers/%i", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)renameServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i", server.identifier] verb:@"PUT" account:account];
}

+ (OpenStackRequest *)deleteServerRequest:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest serversRequest:account method:@"DELETE" path:[NSString stringWithFormat:@"/servers/%i", server.identifier]];
}

+ (RateLimit *)deleteServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i", server.identifier] verb:@"DELETE" account:account];
}

+ (OpenStackRequest *)createServerRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = [server toJSON];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/servers", account.serversURL]];
    NSLog(@"create server: %@", body);
    OpenStackRequest *request = [OpenStackRequest request:account method:@"POST" url:url];    
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)createServerLimit:(OpenStackAccount *)account {
    return [OpenStackRequest limitForPath:@"/servers" verb:@"POST" account:account];
}

- (Server *)server {
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dict = [[parser objectWithString:[self responseString]] objectForKey:@"server"];
    Server *server = [Server fromJSON:dict];
    [parser release];
    return server;
}

+ (OpenStackRequest *)resizeServerRequest:(OpenStackAccount *)account server:(Server *)server flavor:(Flavor *)flavor {
	NSString *body = [NSString stringWithFormat:@"{ \"resize\": { \"flavorId\": %i } }", flavor.identifier];
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)resizeServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}

+ (OpenStackRequest *)confirmResizeServerRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = @"{ \"confirmResize\": null }";
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)confirmResizeServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}

+ (OpenStackRequest *)revertResizeServerRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = @"{ \"revertResize\": null }";
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)revertResizeServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}

+ (OpenStackRequest *)rebuildServerRequest:(OpenStackAccount *)account server:(Server *)server image:(Image *)image {
	NSString *body = [NSString stringWithFormat:@"{ \"rebuild\": { \"imageId\": %i } }", image.identifier];
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)rebuildServerLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/action", server.identifier] verb:@"POST" account:account];
}


+ (OpenStackRequest *)getBackupScheduleRequest:(OpenStackAccount *)account server:(Server *)server {    
    return [OpenStackRequest serversRequest:account method:@"GET" path:[NSString stringWithFormat:@"/servers/%i/backup_schedule", server.identifier]];
}

+ (RateLimit *)getBackupScheduleLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/backup_schedule", server.identifier] verb:@"GET" account:account];
}

+ (OpenStackRequest *)updateBackupScheduleRequest:(OpenStackAccount *)account server:(Server *)server {
	NSString *body = [NSString stringWithFormat:@"{ \"backupSchedule\": { \"enabled\": true, \"weekly\": \"%@\", \"daily\": \"%@\" } }", server.backupSchedule.weekly, server.backupSchedule.daily];
    OpenStackRequest *request = [OpenStackRequest serversRequest:account method:@"POST" path:[NSString stringWithFormat:@"/servers/%i/backup_schedule", server.identifier]];	
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (RateLimit *)updateBackupScheduleLimit:(OpenStackAccount *)account server:(Server *)server {
    return [OpenStackRequest limitForPath:[NSString stringWithFormat:@"/servers/%i/backup_schedule", server.identifier] verb:@"POST" account:account];
}

- (BackupSchedule *)backupSchedule {
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary *dict = [[parser objectWithString:[self responseString]] objectForKey:@"backupSchedule"];
    BackupSchedule *backupSchedule = [BackupSchedule fromJSON:dict];
    [parser release];
    return backupSchedule;
}

#pragma mark -
#pragma mark Object Storage Requests

+ (OpenStackRequest *)getStorageAccountInfoRequest:(OpenStackAccount *)account {
    return [OpenStackRequest filesRequest:account method:@"HEAD" path:@""];
}

+ (OpenStackRequest *)getContainersRequest:(OpenStackAccount *)account {
    return [OpenStackRequest filesRequest:account method:@"GET" path:@""];
}

- (NSMutableDictionary *)containers {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [parser objectWithString:[self responseString]];
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Container *container = [Container fromJSON:dict];
        [objects setObject:container forKey:container.name];
    }
    
    [parser release];
    return objects;
}

+ (OpenStackRequest *)createContainerRequest:(OpenStackAccount *)account container:(Container *)container {    
    return [OpenStackRequest filesRequest:account method:@"PUT" path:[[NSString stringWithFormat:@"/%@", container.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (OpenStackRequest *)deleteContainerRequest:(OpenStackAccount *)account container:(Container *)container {
    return [OpenStackRequest filesRequest:account method:@"DELETE" path:[[NSString stringWithFormat:@"/%@", container.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (OpenStackRequest *)getObjectsRequest:(OpenStackAccount *)account container:(Container *)container {
    return [OpenStackRequest filesRequest:account method:@"GET" path:[[NSString stringWithFormat:@"/%@", container.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
}

- (NSMutableDictionary *)objects {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [parser objectWithString:[self responseString]];
    NSMutableDictionary *objects = [[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        StorageObject *object = [StorageObject fromJSON:dict];
        [objects setObject:object forKey:object.name];
    }
    
    [parser release];
    return objects;
}

+ (OpenStackRequest *)getObjectInfoRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object {
    return [OpenStackRequest filesRequest:account method:@"HEAD" path:[[NSString stringWithFormat:@"/%@/%@", container.name, object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
}

+ (OpenStackRequest *)getObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object {
    return [OpenStackRequest filesRequest:account method:@"GET" path:[[NSString stringWithFormat:@"/%@/%@", container.name, object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
}

+ (OpenStackRequest *)writeObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object {
    NSString *fullPath = object.fullPath;
    if ([fullPath characterAtIndex:0] == '/') {
        fullPath = [fullPath substringFromIndex:1];
    }
    
    OpenStackRequest *request = [OpenStackRequest filesRequest:account method:@"PUT" path:[[NSString stringWithFormat:@"/%@/%@", container.name, fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
	[request setPostBody:[NSMutableData dataWithData:object.data]];
    [request.requestHeaders setObject:object.contentType forKey:@"Content-Type"];
	return request;
}

+ (OpenStackRequest *)writeObjectMetadataRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object {
    return nil;
}

+ (OpenStackRequest *)deleteObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object {
    if ([object.fullPath characterAtIndex:0] == '/') {
        return [OpenStackRequest filesRequest:account method:@"DELETE" path:[[NSString stringWithFormat:@"/%@%@", container.name, object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        return [OpenStackRequest filesRequest:account method:@"DELETE" path:[[NSString stringWithFormat:@"/%@/%@", container.name, object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)releaseBackupBlocksOnMainThread {
	NSMutableArray *blocks = [NSMutableArray array];
	if (backupCompletionBlock) {
		[blocks addObject:backupCompletionBlock];
		[backupCompletionBlock release];
		backupCompletionBlock = nil;
	}
	if (backupFailureBlock) {
		[blocks addObject:backupFailureBlock];
		[backupFailureBlock release];
		backupFailureBlock = nil;
	}
	[[self class] performSelectorOnMainThread:@selector(releaseBackupBlocks:) withObject:blocks waitUntilDone:[NSThread isMainThread]];
}

// Always called on main thread
+ (void)releaseBackupBlocks:(NSArray *)blocks {
	// Blocks will be released when this method exits
}

- (void)dealloc {
    [account release];
    [self releaseBackupBlocksOnMainThread];
    [super dealloc];
}

@end
