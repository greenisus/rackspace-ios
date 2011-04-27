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
    
    NSArray *sortedImages;
    NSArray *sortedFlavors;
    NSArray *sortedServers;
    NSArray *sortedLoadBalancers;

    id getLimitsObserver;
    id getServersObserver;
    id getImagesObserver;
    id getFlavorsObserver;
    
    NSInteger lastUsedFlavorId;
    NSInteger lastUsedImageId;
    
    NSInteger containerCount;
    unsigned long long totalBytesUsed;
    
    NSMutableDictionary *containers;
    NSArray *sortedContainers; 
    
    BOOL flaggedForDelete;
    
    NSMutableDictionary *serversByHost;
}

@property (assign) BOOL hasBeenRefreshed;
@property (retain) NSString *uuid;
@property (retain) Provider *provider;
@property (retain) NSString *username;
@property (retain) NSString *apiKey;
@property (retain) NSString *authToken;
@property (retain) NSMutableDictionary *images;
@property (retain) NSDictionary *flavors;
@property (retain) NSMutableDictionary *servers;
@property (retain) NSURL *serversURL;
@property (retain) NSURL *filesURL;
@property (retain) NSURL *cdnURL;
@property (retain) NSArray *rateLimits;
@property (retain) AccountManager *manager;
@property (retain) NSArray *sortedImages;
@property (retain) NSArray *sortedFlavors;
@property (retain) NSArray *sortedServers;
@property (retain) NSArray *sortedRateLimits;
@property (assign) NSInteger lastUsedFlavorId;
@property (assign) NSInteger lastUsedImageId;
@property (assign) NSInteger containerCount;
@property (assign) unsigned long long totalBytesUsed;
@property (retain) NSMutableDictionary *containers;
@property (retain) NSArray *sortedContainers;
@property (assign) BOOL flaggedForDelete;
@property (retain) NSMutableDictionary *loadBalancers;
@property (retain) NSArray *sortedLoadBalancers;
@property (retain) NSMutableDictionary *serversByHost;

+ (NSArray *)accounts;
- (BOOL)persist;
+ (BOOL)persist:(NSArray *)accountArray;
- (void)refreshCollections;
- (NSArray *)loadBalancerURLs;

- (NSString *)accountNumber;

@end
