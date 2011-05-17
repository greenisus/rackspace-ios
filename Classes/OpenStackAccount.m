//
//  OpenStackAccount.m
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackAccount.h"
#import "Keychain.h"
#import "Provider.h"
#import "Archiver.h"
#import "OpenStackRequest.h"
#import "NSObject+Conveniences.h"
#import "Server.h"
#import "Image.h"
#import "Flavor.h"
#import "AccountManager.h"
#import "LoadBalancer.h"
#import "APICallback.h"


static NSArray *accounts = nil;
static NSMutableDictionary *timers = nil;

@implementation OpenStackAccount

@synthesize uuid, provider, username, images, flavors, servers, serversURL, filesURL, cdnURL, manager, rateLimits,
            sortedImages, sortedFlavors, lastUsedFlavorId, lastUsedImageId, sortedRateLimits,
            containerCount, totalBytesUsed, containers, sortedContainers, hasBeenRefreshed, flaggedForDelete,
            loadBalancers, sortedLoadBalancers, lbProtocols;

+ (void)initialize {
    accounts = [Archiver retrieve:@"accounts"];
    if (accounts == nil) {
        accounts = [[NSArray alloc] init];
        [Archiver persist:accounts key:@"accounts"];
    }
    timers = [[NSMutableDictionary alloc] initWithCapacity:[accounts count]];
}

// no sense wasting space by storing sorted arrays, so override the getters to be sure 
// we at least return something

- (NSArray *)sortedImages {
    if (!sortedImages || [sortedImages count] != [images count]) {
        NSLog(@"%@", [self.images allValues]);
        sortedImages = [[NSArray alloc] initWithArray:[[self.images allValues] sortedArrayUsingSelector:@selector(compare:)]];
    }
    return sortedImages;
}

- (NSArray *)sortedFlavors {
    if (!sortedFlavors || [sortedFlavors count] != [flavors count]) {
        sortedFlavors = [[NSArray alloc] initWithArray:[[self.flavors allValues] sortedArrayUsingSelector:@selector(compare:)]];
    }
    return sortedFlavors;
}

- (NSArray *)sortedServers {
    return [[self.servers allValues] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)sortedRateLimits {
    if (!sortedRateLimits || [sortedRateLimits count] != [rateLimits count]) {
        sortedRateLimits = [[NSArray alloc] initWithArray:[self.rateLimits sortedArrayUsingSelector:@selector(compare:)]];
    }
    return sortedRateLimits;
}

- (NSArray *)sortedContainers {
    if (!sortedContainers || [sortedContainers count] != [containers count]) {
        sortedContainers = [[NSArray alloc] initWithArray:[[self.containers allValues] sortedArrayUsingSelector:@selector(compare:)]];
    }
    return sortedContainers;
}

- (NSArray *)sortedLoadBalancers {
    if (!sortedLoadBalancers || [sortedLoadBalancers count] != [sortedLoadBalancers count]) {
        NSMutableArray *allLoadBalancers = [[NSMutableArray alloc] init];
        for (NSString *endpoint in self.loadBalancers) {
            NSDictionary *lbs = [self.loadBalancers objectForKey:endpoint];
            NSLog(@"lbs for %@: %@", endpoint, lbs);
            for (NSString *key in lbs) {
                [allLoadBalancers addObject:[lbs objectForKey:key]];
            }
        }
        sortedLoadBalancers = [[NSArray alloc] initWithArray:[allLoadBalancers sortedArrayUsingSelector:@selector(compare:)]];
    }
    return sortedLoadBalancers;
}

#pragma mark -
#pragma mark Collections API Management

- (void)observeGetLimits:(OpenStackRequest *)request {
    self.rateLimits = [request rateLimits];
    [[NSNotificationCenter defaultCenter] removeObserver:getLimitsObserver];
}

- (void)refreshCollections {
    NSLog(@"Refreshing collections for %@", self.username);
    NSLog(@"servers URL: %@", self.serversURL);
    
    if (!self.manager) {
        self.manager = [[AccountManager alloc] init];
        self.manager.account = self;
    }

    [[self.manager authenticate] success:^(OpenStackRequest *request){
        
        [self.manager getImages];
        [self.manager getFlavors];
        //[self.manager getServers];
        [self.manager getLimits];
        //[self.manager getContainers];
        
        //[self.manager getStorageAccountInfo];
        
        for (NSString *endpoint in [self loadBalancerURLs]) {
            [self.manager getLoadBalancers:endpoint];
        }
        
        // handle success; don't worry about failure
        getLimitsObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getLimitsSucceeded" object:self
                                                                               queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
                             {
                                 [self performSelectorOnMainThread:@selector(observeGetLimits:) withObject:[notification.userInfo objectForKey:@"request"] waitUntilDone:NO];
                             }];
    } failure:^(OpenStackRequest *request){
    }];
    
    NSLog(@"End refreshing method");
}

#pragma mark -
#pragma mark Serialization

- (void)loadTimer {    
    if (![timers objectForKey:uuid]) {
//        if (!hasBeenRefreshed) {
//            [self refreshCollections];
//        }
        /*
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self.manager selector:@selector(getServers) userInfo:nil repeats:NO];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kOpenStackPollingFrequency * 20 target:self selector:@selector(refreshCollections) userInfo:nil repeats:YES];
        [timers setObject:timer forKey:uuid];
         */
    }
}

- (id)copyWithZone:(NSZone *)zone {
    OpenStackAccount *copy = [[OpenStackAccount allocWithZone:zone] init];
    copy.uuid = self.uuid;
    copy.provider = self.provider;
    copy.username = self.username;
    copy.apiKey = self.apiKey;
    copy.authToken = self.authToken;
    copy.images = [[NSMutableDictionary alloc] initWithDictionary:self.images];
    copy.flavors = [[NSDictionary alloc] initWithDictionary:self.flavors];
    copy.servers = [[NSMutableDictionary alloc] initWithDictionary:self.servers];
    copy.serversURL = self.serversURL;
    copy.filesURL = self.filesURL;
    copy.cdnURL = self.cdnURL;
    copy.rateLimits = [[NSArray alloc] initWithArray:self.rateLimits];
    copy.lastUsedFlavorId = self.lastUsedFlavorId;
    copy.lastUsedImageId = self.lastUsedImageId;
    copy.containerCount = self.containerCount;
    copy.totalBytesUsed = self.totalBytesUsed;
    copy.containers = self.containers;
    copy.loadBalancers = self.loadBalancers;
    manager = [[AccountManager alloc] init];
    manager.account = copy;
    return copy;
}

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:uuid forKey:@"uuid"];
    [coder encodeObject:provider forKey:@"provider"];
    [coder encodeObject:username forKey:@"username"];
    [coder encodeObject:images forKey:@"images"];
    [coder encodeObject:flavors forKey:@"flavors"];
//    [coder encodeObject:servers forKey:@"servers"];
    [coder encodeObject:serversURL forKey:@"serversURL"];
    [coder encodeObject:filesURL forKey:@"filesURL"];
    [coder encodeObject:cdnURL forKey:@"cdnURL"];
    [coder encodeObject:rateLimits forKey:@"rateLimits"];
    [coder encodeInt:lastUsedFlavorId forKey:@"lastUsedFlavorId"];
    [coder encodeInt:lastUsedImageId forKey:@"lastUsedImageId"];
    [coder encodeInt:containerCount forKey:@"containerCount"];
    [coder encodeInt:totalBytesUsed forKey:@"totalBytesUsed"];
//    [coder encodeObject:containers forKey:@"containers"];
//    [coder encodeObject:loadBalancers forKey:@"loadBalancers"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        uuid = [[coder decodeObjectForKey:@"uuid"] retain];
        provider = [[coder decodeObjectForKey:@"provider"] retain];
        username = [[coder decodeObjectForKey:@"username"] retain];
        images = [[coder decodeObjectForKey:@"images"] retain];
        flavors = [[coder decodeObjectForKey:@"flavors"] retain];
//        servers = [[coder decodeObjectForKey:@"servers"] retain];
        serversURL = [[coder decodeObjectForKey:@"serversURL"] retain];
        filesURL = [[coder decodeObjectForKey:@"filesURL"] retain];
        cdnURL = [[coder decodeObjectForKey:@"cdnURL"] retain];
        rateLimits = [[coder decodeObjectForKey:@"rateLimits"] retain];

        [self loadTimer];
        
        lastUsedFlavorId = [coder decodeIntForKey:@"lastUsedFlavorId"];
        lastUsedImageId = [coder decodeIntForKey:@"lastUsedImageId"];
        
        containerCount = [coder decodeIntForKey:@"containerCount"];
        //totalBytesUsed = [coder decodeIntForKey:@"totalBytesUsed"];
        
//        containers = [[coder decodeObjectForKey:@"containers"] retain];
//        loadBalancers = [[coder decodeObjectForKey:@"loadBalancers"] retain];

        manager = [[AccountManager alloc] init];
        manager.account = self;
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        uuid = [[NSString alloc] initWithString:[OpenStackAccount stringWithUUID]];

        [self loadTimer];
        
        manager = [[AccountManager alloc] init];
        manager.account = self;
    }
    return self;
}

+ (NSArray *)accounts {
    if (accounts == nil) {
        accounts = [[Archiver retrieve:@"accounts"] retain];
    }
    return accounts;
}

+ (BOOL)persist:(NSArray *)accountArray {
    accounts = [[NSArray arrayWithArray:accountArray] retain];
    BOOL result = [Archiver persist:accounts key:@"accounts"];
    [accounts release];
    accounts = nil;
    return result;
}

- (BOOL)persist {
    //return NO;
    //*
    if (!flaggedForDelete) {        
        NSMutableArray *accountArr = [NSMutableArray arrayWithArray:[OpenStackAccount accounts]];
        
        BOOL accountPresent = NO;
        for (int i = 0; i < [accountArr count]; i++) {
            OpenStackAccount *account = [accountArr objectAtIndex:i];
            
            if ([account.uuid isEqualToString:self.uuid]) {
                accountPresent = YES;
                [accountArr replaceObjectAtIndex:i withObject:self];
                break;
            }
        }
            
        if (!accountPresent) {
            [accountArr insertObject:self atIndex:0];
        }
        
        BOOL result = [Archiver persist:[NSArray arrayWithArray:accountArr] key:@"accounts"];    
        [accounts release];
        accounts = nil;
        return result;
    } else {
        return NO;
    }
    //*/
}

// the API key and auth token are stored in the Keychain, so overriding the 
// getter and setter to abstract the encryption away and make it easy to use

- (NSString *)apiKeyKeychainKey {
    return [NSString stringWithFormat:@"%@-apiKey", self.uuid];
}

- (NSString *)apiKey {    
    return [Keychain getStringForKey:[self apiKeyKeychainKey]];
}

- (void)setApiKey:(NSString *)newAPIKey {
    [Keychain setString:newAPIKey forKey:[self apiKeyKeychainKey]];
}

- (NSString *)authTokenKeychainKey {
    return [NSString stringWithFormat:@"%@-authToken", self.uuid];
}

- (NSString *)authToken {
    return [Keychain getStringForKey:[self authTokenKeychainKey]];
}

- (void)setAuthToken:(NSString *)newAuthToken {
    [Keychain setString:newAuthToken forKey:[self authTokenKeychainKey]];
}

- (NSString *)accountNumber {
    NSString *accountNumber = nil;
    if (self.serversURL) {
        NSString *surl = [self.serversURL description];
        accountNumber = [[surl componentsSeparatedByString:@"/"] lastObject];
    }
    return accountNumber;
}

- (NSArray *)loadBalancerURLs {
    NSString *accountNumber = [self accountNumber];
    
    if (accountNumber) {
        NSString *ord = [NSString stringWithFormat:@"https://ord.loadbalancers.api.rackspacecloud.com/v1.0/%@", accountNumber];
        NSString *dfw = [NSString stringWithFormat:@"https://dfw.loadbalancers.api.rackspacecloud.com/v1.0/%@", accountNumber];

        NSLog(@"ord: %@", ord);
        
        return [NSArray arrayWithObjects:ord, dfw, nil];
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    NSTimer *timer = [timers objectForKey:uuid];
    [timer invalidate];
    [timers removeObjectForKey:uuid];
    
    [uuid release];
    [manager release];
    [provider release];
    [username release];
    [flavors release];
    [images release];
    [servers release];
    [serversURL release];
    [filesURL release];
    [cdnURL release];
    [rateLimits release];
    [sortedImages release];
    [sortedFlavors release];
    [sortedRateLimits release];
    [containers release];
    [sortedContainers release];
    [loadBalancers release];
    [sortedLoadBalancers release];
    [lbProtocols release];
    
    [super dealloc];
}

@end
