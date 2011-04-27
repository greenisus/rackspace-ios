//
//  Provider.m
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Provider.h"
#import "JSON.h"


static NSArray *providers = nil;

@implementation Provider

@synthesize name, authEndpointURL, authHelpMessage, rssFeeds, contactURLs, logoURLs, logoObjects;

+ (void)initialize {
    NSString *json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"openstack_providers" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:json] objectForKey:@"providers"];
    NSMutableArray *providerObjects = [[[NSMutableArray alloc] initWithCapacity:[jsonObjects count]] autorelease];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Provider *provider = [Provider fromJSON:dict];
        [providerObjects addObject:provider];   
    }
    [parser release];
    
    providers = [[NSArray alloc] initWithArray:providerObjects]; // TODO: release
}

+ (Provider *)fromJSON:(NSDictionary *)dict {
    Provider *provider = [[[Provider alloc] init] autorelease];
    provider.name = [dict objectForKey:@"name"];
    provider.authEndpointURL = [NSURL URLWithString:[dict objectForKey:@"auth_endpoint_url"]];    
    provider.authHelpMessage = [dict objectForKey:@"auth_help_message"];
    provider.rssFeeds = [dict objectForKey:@"rss_feeds"];    
    provider.contactURLs = [dict objectForKey:@"contact_urls"];
    provider.logoURLs = [dict objectForKey:@"logos"];
    
    return provider;
}

+ (NSArray *)providers {
    
    if (providers == nil) {    
        NSString *json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"openstack_providers" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
        SBJSON *parser = [[SBJSON alloc] init];
        NSArray *jsonObjects = [[parser objectWithString:json] objectForKey:@"providers"];
        NSMutableArray *providerObjects = [[[NSMutableArray alloc] initWithCapacity:[jsonObjects count]] autorelease];
        
        for (int i = 0; i < [jsonObjects count]; i++) {
            NSDictionary *dict = [jsonObjects objectAtIndex:i];
            Provider *provider = [Provider fromJSON:dict];
            [providerObjects addObject:provider];   
        }
        [parser release];
        
        providers = [NSArray arrayWithArray:providerObjects];
    }
    
    return providers;
}

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:authEndpointURL forKey:@"authEndpointURL"];
    [coder encodeObject:authHelpMessage forKey:@"authHelpMessage"];
    [coder encodeObject:rssFeeds forKey:@"rssFeeds"];
    [coder encodeObject:contactURLs forKey:@"contactURLs"];
    [coder encodeObject:logoURLs forKey:@"logoURLs"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        name = [[coder decodeObjectForKey:@"name"] retain];
        authEndpointURL = [[coder decodeObjectForKey:@"authEndpointURL"] retain];
        authHelpMessage = [[coder decodeObjectForKey:@"authHelpMessage"] retain];
        rssFeeds = [[coder decodeObjectForKey:@"rssFeeds"] retain];
        contactURLs = [[coder decodeObjectForKey:@"contactURLs"] retain];
        logoURLs = [[coder decodeObjectForKey:@"logoURLs"] retain];        
    }
    return self;
}

#pragma mark -
#pragma mark HTTP Logo Requests

- (BOOL)isRackspace {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"rackspacecloud.com" options:NSRegularExpressionCaseInsensitive error:nil];            
    NSInteger matches = [regex numberOfMatchesInString:[self.authEndpointURL host] options:0 range:NSMakeRange(0, [[self.authEndpointURL host] length])];    
    return matches > 0;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [name release];
    [authEndpointURL release];
    [authHelpMessage release];    
    [rssFeeds release];
    [contactURLs release];
    [logoURLs release];
    [logoObjects release];
    [super dealloc];
}

@end
