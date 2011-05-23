//
//  Account.h
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class Provider;

@class AccountManager;

// named OpenStackAccount instead of Account to prevent collisions with
// the MessageUI framework
@interface OpenStackAccount : NSObject <NSCoding, NSCopying> {
    
    BOOL hasBeenRefreshed;
    
    NSString *uuid;
    Provider *provider;
    NSString *username;
    NSMutableDictionary *images;
    NSDictionary *flavors;
    NSMutableDictionary *servers;
    NSURL *serversURL;
    NSURL *filesURL;
    NSURL *cdnURL;
    NSArray *rateLimits;
    
    // this is a dictionary of dictionaries:
    // { "endpoint1": { "123": { ... }, "456": { ... } },
    //   "endpoint2": { "789": { ... }, "321": { ... } }}
    NSMutableDictionary *loadBalancers;
    
    AccountManager *manager;
    
    id getLimitsObserver;
    id getServersObserver;
    id getImagesObserver;
    id getFlavorsObserver;
    
    NSInteger lastUsedFlavorId;
    NSInteger lastUsedImageId;
    
    NSInteger containerCount;
    unsigned long long totalBytesUsed;
    
    NSMutableDictionary *containers;
    
    BOOL flaggedForDelete;
    
    NSMutableArray *lbProtocols;
}

@property (nonatomic, assign) BOOL hasBeenRefreshed;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) Provider *provider;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *apiKey;
@property (nonatomic, retain) NSString *authToken;
@property (nonatomic, retain) NSMutableDictionary *images;
@property (nonatomic, retain) NSDictionary *flavors;
@property (nonatomic, retain) NSMutableDictionary *servers;
@property (nonatomic, retain) NSURL *serversURL;
@property (nonatomic, retain) NSURL *filesURL;
@property (nonatomic, retain) NSURL *cdnURL;
@property (nonatomic, retain) NSArray *rateLimits;
@property (nonatomic, retain) AccountManager *manager;
@property (nonatomic, assign) NSInteger lastUsedFlavorId;
@property (nonatomic, assign) NSInteger lastUsedImageId;
@property (nonatomic, assign) NSInteger containerCount;
@property (nonatomic, assign) unsigned long long totalBytesUsed;
@property (nonatomic, retain) NSMutableDictionary *containers;
@property (nonatomic, assign) BOOL flaggedForDelete;
@property (nonatomic, retain) NSMutableDictionary *loadBalancers;
@property (nonatomic, retain) NSMutableArray *lbProtocols;

+ (NSArray *)accounts;
- (void)persist;
+ (void)persist:(NSArray *)accountArray;
- (void)refreshCollections;
- (NSArray *)loadBalancerURLs;

- (NSString *)accountNumber;

- (NSArray *)sortedServers;
- (NSArray *)sortedImages;
- (NSArray *)sortedFlavors;
- (NSArray *)sortedRateLimits;
- (NSArray *)sortedContainers;
- (NSArray *)sortedLoadBalancers;

@end
