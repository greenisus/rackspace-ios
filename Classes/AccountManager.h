//
//  AccountManager.h
//  OpenStack
//
//  Created by Mike Mayo on 10/21/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

// this class performs API calls on accounts and broadcasts NSNotifications to any other
// object that chooses to observe the notification

@class OpenStackAccount, Server, Flavor, Image, Container, StorageObject, OpenStackRequest, ASINetworkQueue, APICallback;

@interface AccountManager : NSObject {
    OpenStackAccount *account;
    ASINetworkQueue *queue;
}

@property (retain) ASINetworkQueue *queue;

@property (retain) OpenStackAccount *account;

- (NSString *)notificationName:(NSString *)key identifier:(NSInteger)identifier;
- (void)notify:(NSString *)name request:(OpenStackRequest *)request;
- (void)notify:(NSString *)name request:(OpenStackRequest *)request object:(id)object;
    
// compute

- (void)getLimits;
- (void)softRebootServer:(Server *)server;
- (void)hardRebootServer:(Server *)server;
- (void)changeAdminPassword:(Server *)server password:(NSString *)password;
- (APICallback *)renameServer:(Server *)server name:(NSString *)name;
- (void)deleteServer:(Server *)server;
- (void)createServer:(Server *)server;
- (void)resizeServer:(Server *)server flavor:(Flavor *)flavor;
- (void)confirmResizeServer:(Server *)server;
- (void)revertResizeServer:(Server *)server;
- (void)rebuildServer:(Server *)server image:(Image *)image;
- (void)getBackupSchedule:(Server *)server;
- (void)updateBackupSchedule:(Server *)server;

- (void)getServers;
- (void)getImages;
- (void)getFlavors;
- (void)getImage:(Server *)server;

// object storage

- (void)getStorageAccountInfo;
- (void)getContainers;
- (void)createContainer:(Container *)container;
- (void)deleteContainer:(Container *)container;

- (void)getObjects:(Container *)container;
- (void)getObjectInfo:(Container *)container object:(StorageObject *)object;
- (void)getObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate;
- (void)writeObject:(Container *)container object:(StorageObject *)object downloadProgressDelegate:(id)downloadProgressDelegate;
- (void)writeObjectMetadata:(Container *)container object:(StorageObject *)object;
- (void)deleteObject:(Container *)container object:(StorageObject *)object;

- (void)updateCDNContainer:(Container *)container;

// load balancing

- (APICallback *)getLoadBalancers:(NSString *)endpoint;

@end
