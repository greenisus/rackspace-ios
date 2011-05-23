//
//  OpenStackRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ASIHTTPRequest.h"

#define kOpenStackPollingFrequency 20.0

@class OpenStackAccount, Server, Image, RateLimit, Flavor, Container, StorageObject, BackupSchedule, LoadBalancer, APICallback, Domain, Nameserver, Record;

@interface OpenStackRequest : ASIHTTPRequest {
    OpenStackAccount *account;
    BOOL retried;
    OpenStackRequest *retriedRequest;
    ASIBasicBlock backupCompletionBlock;
    ASIBasicBlock backupFailureBlock;
    APICallback *callback;
    NSInteger retriedCount;
}

@property (nonatomic, retain) OpenStackAccount *account;
@property (nonatomic, retain) APICallback *callback;
@property (nonatomic, assign) NSInteger retriedCount;

- (void)setCompletionBlock:(ASIBasicBlock)aCompletionBlock;
- (void)setFailedBlock:(ASIBasicBlock)aFailedBlock;

- (BOOL)isSuccess;
- (void)notify;
- (void)notify:(NSString *)name;

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url;
+ (id)serversRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path;
+ (id)filesRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path;
+ (id)cdnRequest:(OpenStackAccount *)account method:(NSString *)method path:(NSString *)path;

#pragma mark -
#pragma mark Authentication

+ (OpenStackRequest *)authenticationRequest:(OpenStackAccount *)account;

#pragma mark -
#pragma mark Compute Requests

#pragma mark Rate Limits

+ (OpenStackRequest *)getLimitsRequest:(OpenStackAccount *)account;
- (NSDictionary *)limits;
- (NSArray *)rateLimits;

#pragma mark Collections

+ (OpenStackRequest *)getServersRequest:(OpenStackAccount *)account;
- (NSDictionary *)servers;

+ (OpenStackRequest *)getServerRequest:(OpenStackAccount *)account serverId:(NSInteger)serverId;

+ (OpenStackRequest *)getImagesRequest:(OpenStackAccount *)account;
- (NSDictionary *)images;

+ (OpenStackRequest *)getImageRequest:(OpenStackAccount *)account imageId:(NSInteger)imageId;
- (Image *)image;

+ (OpenStackRequest *)getFlavorsRequest:(OpenStackAccount *)account;
- (NSDictionary *)flavors;

#pragma mark Server Actions

+ (OpenStackRequest *)softRebootServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)softRebootServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)hardRebootServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)hardRebootServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)changeServerAdminPasswordRequest:(OpenStackAccount *)account server:(Server *)server password:(NSString *)password;
+ (RateLimit *)changeServerAdminPasswordLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)renameServerRequest:(OpenStackAccount *)account server:(Server *)server name:(NSString *)name;
+ (RateLimit *)renameServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)deleteServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)deleteServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)createServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)createServerLimit:(OpenStackAccount *)account;

+ (OpenStackRequest *)resizeServerRequest:(OpenStackAccount *)account server:(Server *)server flavor:(Flavor *)flavor;
+ (RateLimit *)resizeServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)confirmResizeServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)confirmResizeServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)revertResizeServerRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)revertResizeServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)rebuildServerRequest:(OpenStackAccount *)account server:(Server *)server image:(Image *)image;
+ (RateLimit *)rebuildServerLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)getBackupScheduleRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)getBackupScheduleLimit:(OpenStackAccount *)account server:(Server *)server;

+ (OpenStackRequest *)updateBackupScheduleRequest:(OpenStackAccount *)account server:(Server *)server;
+ (RateLimit *)updateBackupScheduleLimit:(OpenStackAccount *)account server:(Server *)server;

- (Server *)server;
- (BackupSchedule *)backupSchedule;

#pragma mark -
#pragma mark Object Storage Requests

+ (OpenStackRequest *)getStorageAccountInfoRequest:(OpenStackAccount *)account;
+ (OpenStackRequest *)getContainersRequest:(OpenStackAccount *)account;
- (NSMutableDictionary *)containers;

+ (OpenStackRequest *)createContainerRequest:(OpenStackAccount *)account container:(Container *)container;
+ (OpenStackRequest *)deleteContainerRequest:(OpenStackAccount *)account container:(Container *)container;

+ (OpenStackRequest *)getObjectsRequest:(OpenStackAccount *)account container:(Container *)container;
- (NSMutableDictionary *)objects;

+ (OpenStackRequest *)getObjectInfoRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object;
+ (OpenStackRequest *)getObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object;
+ (OpenStackRequest *)writeObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object;
+ (OpenStackRequest *)writeObjectMetadataRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object;
+ (OpenStackRequest *)deleteObjectRequest:(OpenStackAccount *)account container:(Container *)container object:(StorageObject *)object;



@end
