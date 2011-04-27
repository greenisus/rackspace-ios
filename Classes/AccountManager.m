//
//  AccountManager.m
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountManager.h"
#import "OpenStackAccount.h"
#import "OpenStackRequest.h"
#import "Server.h"
#import "Provider.h"
#import "Image.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "GetServersRequest.h"
#import "GetContainersRequest.h"
#import "GetObjectsRequest.h"
#import "GetImagesRequest.h"
#import "ASINetworkQueue.h"
#import "UpdateCDNContainerRequest.h"
#import "GetFlavorsRequest.h"
#import "LoadBalancer.h"
#import "LoadBalancerRequest.h"
#import "APICallback.h"


@implementation AccountManager

@synthesize account, queue;

#pragma mark - Callbacks

- (APICallback *)callbackWithRequest:(id)request success:(APIResponseBlock)success failure:(APIResponseBlock)failure {
    APICallback *callback = [[[APICallback alloc] initWithAccount:self.account request:request] autorelease];
    ((OpenStackRequest *)request).delegate = self;
    ((OpenStackRequest *)request).callback = callback;    
    [request setCompletionBlock:^{
        if ([request isSuccess]) {
            success(request);
            [request notify];
        } else {
            failure(request);
            [request notify];
        }
    }];
    [request setFailedBlock:^{
        failure(request);
        [request notify];
    }];
    [request startAsynchronous];    
    return callback;
}

- (APICallback *)callbackWithRequest:(id)request success:(APIResponseBlock)success {
    return [self callbackWithRequest:request success:success failure:^(OpenStackRequest *request){}];
}

- (APICallback *)callbackWithRequest:(id)request {
    return [self callbackWithRequest:request success:^(OpenStackRequest *request){} failure:^(OpenStackRequest *request){}];
}

#pragma mark -
#pragma mark Notification

- (NSString *)notificationName:(NSString *)key identifier:(NSInteger)identifier {
    return [NSString stringWithFormat:@"%@-%@-%i", key, self.account.uuid, identifier];
}

- (void)requestFinished:(OpenStackRequest *)request {
    NSString *notificationName = [request.userInfo objectForKey:@"notificationName"];
    id notificationObject = [request.userInfo objectForKey:@"notificationObject"];
    
    if ([request isSuccess]) {
        NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Succeeded", notificationName] object:notificationObject];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Failed", notificationName] object:notificationObject userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)requestFailed:(OpenStackRequest *)request {
    NSString *notificationName = [request.userInfo objectForKey:@"notificationName"];
    id notificationObject = [request.userInfo objectForKey:@"notificationObject"];
    NSNotification *notification = [NSNotification notificationWithName:[NSString stringWithFormat:@"%@Failed", notificationName] object:notificationObject userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)sendRequest:(OpenStackRequest *)request name:(NSString *)name object:(id)notificationObject {
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, notificationObject, nil] forKeys:[NSArray arrayWithObjects:@"notificationName", @"notificationObject", nil]];
    [request startAsynchronous];
}

- (void)notify:(NSString *)name request:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:name object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)notify:(NSString *)name request:(OpenStackRequest *)request object:(id)object {
    NSNotification *notification = [NSNotification notificationWithName:name object:object userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark -
#pragma mark API Calls

#pragma mark Get Limits

- (void)getLimits {
    __block OpenStackRequest *request = [OpenStackRequest getLimitsRequest:self.account];
    request.delegate = self;
    [request setCompletionBlock:^{
        if ([request isSuccess] && [request limits]) {
            self.account.rateLimits = [request rateLimits];
            [self.account persist];
            [self notify:@"getLimitsSucceeded" request:request object:self.account];
        } else {
            [self notify:@"getLimitsFailed" request:request object:self.account];
        }
    }];
    [request setFailedBlock:^{
        [self notify:@"getLimitsFailed" request:request object:self.account];
    }];    
    [request startAsynchronous];
}

#pragma mark Reboot Server

- (void)softRebootServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest softRebootServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        [self notify:([request isSuccess] ? @"rebootSucceeded" : @"rebootFailed") request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request setFailedBlock:^{
        [self notify:@"rebootFailed" request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request startAsynchronous];    
}

- (void)hardRebootServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest hardRebootServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        [self notify:([request isSuccess] ? @"rebootSucceeded" : @"rebootFailed") request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request setFailedBlock:^{
        [self notify:@"rebootFailed" request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request startAsynchronous];
}

#pragma mark Change Admin Password

- (void)changeAdminPassword:(Server *)server password:(NSString *)password {
    __block OpenStackRequest *request = [OpenStackRequest changeServerAdminPasswordRequest:self.account server:server password:password];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        [self notify:([request isSuccess] ? @"changeAdminPasswordSucceeded" : @"changeAdminPasswordFailed") request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request setFailedBlock:^{
        [self notify:@"changeAdminPasswordFailed" request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request startAsynchronous];
}

#pragma mark Rename Server

- (APICallback *)renameServer:(Server *)server name:(NSString *)name {
    __block OpenStackRequest *request = [OpenStackRequest renameServerRequest:self.account server:server name:name];
    return [self callbackWithRequest:request];
}

#pragma mark Delete Server

- (void)deleteServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest deleteServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        [self notify:([request isSuccess] ? @"deleteServerSucceeded" : @"deleteServerFailed") request:request object:[request.userInfo objectForKey:@"server"]];        
        [self notify:([request isSuccess] ? @"deleteServerSucceeded" : @"deleteServerFailed") request:request object:self.account];
    }];
    [request setFailedBlock:^{
        [self notify:@"deleteServerFailed" request:request object:[request.userInfo objectForKey:@"server"]];        
    }];
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    [queue addOperation:request];    
}

#pragma mark Create Server

- (void)createServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest createServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    
    // TODO: make these success block and failure block with "response" arg
    [request setCompletionBlock:^{
        NSLog(@"create server response: %i - %@", request.responseStatusCode, request.responseStatusMessage);
        NSLog(@"body: %@", [request responseString]);            
        [self notify:([request isSuccess] ? @"createServerSucceeded" : @"createServerFailed") request:request object:[request.userInfo objectForKey:@"server"]];        
        [self notify:([request isSuccess] ? @"createServerSucceeded" : @"createServerFailed") request:request object:self.account];
    }];    
    [request setFailedBlock:^{
        NSLog(@"create server response: %i - %@", request.responseStatusCode, request.responseStatusMessage);
        NSLog(@"body: %@", [request responseString]);            
        [self notify:@"createServerFailed" request:request object:[request.userInfo objectForKey:@"server"]];        
    }];
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    [queue addOperation:request];
}

#pragma mark Resize Server

- (void)resizeServer:(Server *)server flavor:(Flavor *)flavor {
    __block OpenStackRequest *request = [OpenStackRequest resizeServerRequest:self.account server:server flavor:flavor];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        NSString *name = [request isSuccess] ? @"resizeServerSucceeded" : @"resizeServerFailed";
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:name identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request setFailedBlock:^{
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:@"resizeServerFailed" identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request startAsynchronous];
}

- (void)confirmResizeServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest confirmResizeServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        NSString *name = [request isSuccess] ? @"confirmResizeServerSucceeded" : @"confirmResizeServerFailed";
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:name identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request setFailedBlock:^{
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:@"confirmResizeServerFailed" identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }];
    [request startAsynchronous];
}

- (void)revertResizeServer:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest revertResizeServerRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        NSString *name = [request isSuccess] ? @"revertResizeServerSucceeded" : @"revertResizeServerFailed";
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:name identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request setFailedBlock:^{
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:@"revertResizeServerFailed" identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request startAsynchronous];
}

- (void)rebuildServer:(Server *)server image:(Image *)image {
    __block OpenStackRequest *request = [OpenStackRequest rebuildServerRequest:self.account server:server image:image];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        NSString *name = [request isSuccess] ? @"rebuildServerSucceeded" : @"rebuildServerFailed";
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:name identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request setFailedBlock:^{
        NSNotification *notification = [NSNotification notificationWithName:[self notificationName:@"rebuildServerFailed" identifier:server.identifier] object:nil userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    [request startAsynchronous];
}

- (void)getBackupSchedule:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest getBackupScheduleRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        server.backupSchedule = [request backupSchedule];
        [self notify:([request isSuccess] ? @"getBackupScheduleSucceeded" : @"getBackupScheduleFailed") request:request object:[request.userInfo objectForKey:@"server"]];
    }];
    [request setFailedBlock:^{
        [self notify:@"getBackupScheduleFailed" request:request object:[request.userInfo objectForKey:@"server"]];        
    }];
    [request startAsynchronous];
}

- (void)updateBackupSchedule:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest updateBackupScheduleRequest:self.account server:server];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:server forKey:@"server"];
    [request setCompletionBlock:^{
        [self notify:([request isSuccess] ? @"updateBackupScheduleSucceeded" : @"updateBackupScheduleFailed") request:request object:[request.userInfo objectForKey:@"server"]];
        [self notify:([request isSuccess] ? @"updateBackupScheduleSucceeded" : @"updateBackupScheduleFailed") request:request object:self.account];
    }];
    [request setFailedBlock:^{
        [self notify:@"updateBackupScheduleFailed" request:request object:[request.userInfo objectForKey:@"server"]];        
        [self notify:@"updateBackupScheduleFailed" request:request object:self.account];        
    }];
    [request startAsynchronous];
}

#pragma mark Get Image

- (void)getImage:(Server *)server {
    __block OpenStackRequest *request = [OpenStackRequest getImageRequest:self.account imageId:server.imageId];
    request.delegate = self;
    request.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:server.imageId] forKey:@"imageId"];
    [request setCompletionBlock:^{
        if ([request isSuccess]) {
            Image *image = [request image];
            image.canBeLaunched = NO;
            [self.account.images setObject:image forKey:[NSNumber numberWithInt:image.identifier]];        
            [self.account persist];        
            [self notify:@"getImageSucceeded" request:request];
        } else {
            [self notify:@"getImageFailed" request:request object:[request.userInfo objectForKey:@"imageId"]];
        }
    }];
    [request setFailedBlock:^{
        [self notify:@"getImageFailed" request:request object:[request.userInfo objectForKey:@"imageId"]];
    }];
    [request startAsynchronous];
}

#pragma mark Get Servers

- (void)getServers {    
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    GetServersRequest *request = [GetServersRequest request:self.account];
    [queue addOperation:request];
}

#pragma mark Get Flavors

- (void)getFlavors {
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    GetFlavorsRequest *request = [GetFlavorsRequest request:self.account];
    [queue addOperation:request];
}

#pragma mark Get Images

- (void)getImages {
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    GetImagesRequest *request = [GetImagesRequest request:self.account];
    [queue addOperation:request];
}

#pragma mark -
#pragma mark Object Storage

- (void)getStorageAccountInfo {
    __block OpenStackRequest *request = [OpenStackRequest getStorageAccountInfoRequest:self.account];
    
    request.delegate = self;
    [request setCompletionBlock:^{
        if ([request isSuccess]) {
            self.account.containerCount = [[[request responseHeaders] objectForKey:@"X-Account-Container-Count"] intValue];
            NSString *numStr = [[request responseHeaders] objectForKey:@"X-Account-Bytes-Used"];
            self.account.totalBytesUsed = strtoull([numStr UTF8String], NULL, 0);
            [self.account persist];
            [self notify:@"getStorageAccountInfoSucceeded" request:request object:self.account];
            [numStr release];
        } else {
            [self notify:@"getStorageAccountInfoFailed" request:request object:self.account];
        }
    }];
    [request setFailedBlock:^{
        [self notify:@"getStorageAccountInfoFailed" request:request object:self.account];
    }];
    [request startAsynchronous];
}

- (void)getContainers {
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    
    GetContainersRequest *request = [GetContainersRequest request:self.account];
    //[request startAsynchronous];
    [queue addOperation:request];
}

- (void)createContainer:(Container *)container {
    OpenStackRequest *request = [OpenStackRequest createContainerRequest:self.account container:container];
    request.delegate = self;
    request.didFinishSelector = @selector(createContainerSucceeded:);
    request.didFailSelector = @selector(createContainerFailed:);
    request.userInfo = [NSDictionary dictionaryWithObject:container forKey:@"container"];
    [request startAsynchronous];
}

- (void)createContainerSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {        
        Container *container = [request.userInfo objectForKey:@"container"];
        [self.account.containers setObject:container forKey:container.name];        
        [self.account persist];
        self.account.containerCount = [self.account.containers count];
        [self notify:@"createContainerSucceeded" request:request object:self.account];
    } else {
        [self notify:@"createContainerFailed" request:request object:self.account];
    }
}

- (void)createContainerFailed:(OpenStackRequest *)request {
    [self notify:@"createContainerFailed" request:request object:self.account];
}

- (void)deleteContainer:(Container *)container {
    OpenStackRequest *request = [OpenStackRequest deleteContainerRequest:self.account container:container];
    request.delegate = self;
    request.didFinishSelector = @selector(deleteContainerSucceeded:);
    request.didFailSelector = @selector(deleteContainerFailed:);
    request.userInfo = [NSDictionary dictionaryWithObject:container forKey:@"container"];
    [request startAsynchronous];
}

- (void)deleteContainerSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess] || [request responseStatusCode] == 404) {
        Container *container = [request.userInfo objectForKey:@"container"];
        [self.account.containers setObject:container forKey:container.name];                
        [self.account persist];        
        [self notify:@"deleteContainerSucceeded" request:request object:self.account];
        [self notify:@"deleteContainerSucceeded" request:request object:[request.userInfo objectForKey:@"container"]];
    } else {
        [self notify:@"deleteContainerFailed" request:request object:self.account];
        [self notify:@"deleteContainerFailed" request:request object:[request.userInfo objectForKey:@"container"]];
    }
}

- (void)deleteContainerFailed:(OpenStackRequest *)request {
    [self notify:@"deleteContainerFailed" request:request object:self.account];
    [self notify:@"deleteContainerFailed" request:request object:[request.userInfo objectForKey:@"container"]];
}

- (void)getObjects:(Container *)container {
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }    
    GetObjectsRequest *request = [GetObjectsRequest request:self.account container:container];
    [queue addOperation:request];
}

- (void)updateCDNContainer:(Container *)container {
    if (![self queue]) {
        [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    }
    UpdateCDNContainerRequest *request = [UpdateCDNContainerRequest request:self.account container:container];
    [queue addOperation:request];
}

- (void)getObjectsSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        Container *container = [request.userInfo objectForKey:@"container"];
        NSMutableDictionary *objects = [request objects];
        container.rootFolder = [Folder folder];
        container.rootFolder.objects = objects;
        [self.account persist];

        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsSucceeded" object:self.account userInfo:[NSDictionary dictionaryWithObject:container forKey:@"container"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)getObjectsFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)getObjectInfo:(Container *)container object:(StorageObject *)object {
    OpenStackRequest *request = [OpenStackRequest getObjectInfoRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(getObjectInfoSucceeded:);
    request.didFailSelector = @selector(getObjectInfoFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)getObjectInfoSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)getObjectInfoFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectInfoFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)getObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate {
    OpenStackRequest *request = [OpenStackRequest getObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.downloadProgressDelegate = downloadProgressDelegate;
    request.showAccurateProgress = YES;    
    request.didFinishSelector = @selector(getObjectSucceeded:);
    request.didFailSelector = @selector(getObjectFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)getObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        Container *container = [request.userInfo objectForKey:@"container"];
        StorageObject *object = [request.userInfo objectForKey:@"object"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];        
        NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", container.name, object.fullPath];
        NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
        NSString *directoryPath = [filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@", object.name] withString:@""];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSData *data = [request responseData];
            if ([data writeToFile:filePath atomically:YES]) {
                NSNotification *notification = [NSNotification notificationWithName:@"getObjectSucceeded" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            } else {
                NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        } else {
            NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)getObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"getObjectFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)writeObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate {
    OpenStackRequest *request = [OpenStackRequest writeObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(writeObjectSucceeded:);
    request.didFailSelector = @selector(writeObjectFailed:);
    request.uploadProgressDelegate = downloadProgressDelegate;
    request.showAccurateProgress = YES;
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)writeObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
        NSNotification *notification = [NSNotification notificationWithName:@"writeObjectSucceeded" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"writeObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)writeObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"writeObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)writeObjectMetadata:(Container *)container object:(StorageObject *)object {
    OpenStackRequest *request = [OpenStackRequest writeObjectMetadataRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(writeObjectMetadataSucceeded:);
    request.didFailSelector = @selector(writeObjectMetadataFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)writeObjectMetadataSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess]) {
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"getObjectsFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)writeObjectMetadataFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"writeObjectMetadataFailed" object:self.account userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)deleteObject:(Container *)container object:(StorageObject *)object {
    OpenStackRequest *request = [OpenStackRequest deleteObjectRequest:self.account container:container object:object];
    request.delegate = self;
    request.didFinishSelector = @selector(deleteObjectSucceeded:);
    request.didFailSelector = @selector(deleteObjectFailed:);
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:container, object, nil] forKeys:[NSArray arrayWithObjects:@"container", @"object", nil]];
    [request startAsynchronous];
}

- (void)deleteObjectSucceeded:(OpenStackRequest *)request {
    if ([request isSuccess] || [request responseStatusCode] == 404) {
        NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectSucceeded" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else {
        NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)deleteObjectFailed:(OpenStackRequest *)request {
    NSNotification *notification = [NSNotification notificationWithName:@"deleteObjectFailed" object:[request.userInfo objectForKey:@"object"] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark -
#pragma mark Load Balancing

- (APICallback *)getLoadBalancers:(NSString *)endpoint {
    __block LoadBalancerRequest *request = [LoadBalancerRequest getLoadBalancersRequest:self.account endpoint:endpoint];
    return [self callbackWithRequest:request success:^(OpenStackRequest *request) {
        if (!self.account.loadBalancers) {
            self.account.loadBalancers = [[NSMutableDictionary alloc] initWithCapacity:2];
        }
        [self.account.loadBalancers setObject:[(LoadBalancerRequest *)request loadBalancers] forKey:endpoint];
        [self.account persist];            
        for (LoadBalancer *lb in self.account.sortedLoadBalancers) {
            NSLog(@"Load Balancer at %@: %@", endpoint, lb.name);
        }
    }];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [account release];
    [super dealloc];
}

@end
