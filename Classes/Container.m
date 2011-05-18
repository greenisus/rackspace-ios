//
//  Container.m
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "NSObject+NSCoding.h"


@implementation Container

// regular container attributes
@synthesize name, count, bytes;

// CDN container attributes
@synthesize cdnEnabled, ttl, cdnURL, logRetention, referrerACL, useragentACL, rootFolder;

@synthesize hasEverBeenCDNEnabled;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeInt:count forKey:@"count"];
    [coder encodeInt:bytes forKey:@"bytes"];
    [coder encodeBool:cdnEnabled forKey:@"cdnEnabled"];
    [coder encodeInt:ttl forKey:@"ttl"];
    [coder encodeObject:cdnURL forKey:@"cdnURL"];
    [coder encodeBool:logRetention forKey:@"logRetention"];
    [coder encodeObject:referrerACL forKey:@"referrerACL"];
    [coder encodeObject:useragentACL forKey:@"useragentACL"];
    [coder encodeObject:rootFolder forKey:@"rootFolder"];
    [coder encodeBool:hasEverBeenCDNEnabled forKey:@"hasEverBeenCDNEnabled"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        name = [[coder decodeObjectForKey:@"name"] retain];
        @try {
            count = [coder decodeIntForKey:@"count"];
            bytes = [coder decodeIntForKey:@"bytes"];
            cdnEnabled = [coder decodeBoolForKey:@"cdnEnabled"];
            ttl = [coder decodeIntForKey:@"ttl"];
            logRetention = [coder decodeBoolForKey:@"logRetention"];
            hasEverBeenCDNEnabled = [coder decodeBoolForKey:@"hasEverBeenCDNEnabled"];
        }
        @catch (NSException *exception) {
            // we want to encode as primitives and the auto encode/decode apparently
            // wasn't working properly.  this try/catch block prevents a potential
            // crash for users who have been encoded/decoded the other way
            count = 0;
            bytes = 0;
            cdnEnabled = NO;
            ttl = 0;
            logRetention = NO;
            hasEverBeenCDNEnabled = NO;
        }
        cdnURL = [[coder decodeObjectForKey:@"cdnURL"] retain];
        referrerACL = [[coder decodeObjectForKey:@"referrerACL"] retain];
        useragentACL = [[coder decodeObjectForKey:@"useragentACL"] retain];
        rootFolder = [[coder decodeObjectForKey:@"rootFolder"] retain];
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (Container *)fromJSON:(NSDictionary *)dict {
    
    Container *container = [[[Container alloc] init] autorelease];
    
    // regular attributes
    container.name = [dict objectForKey:@"name"];
    
    // if count is in here, we're parsing from the object storage API
    if ([dict objectForKey:@"count"]) {
        container.count = [[dict objectForKey:@"count"] intValue];
        container.bytes = [[dict objectForKey:@"bytes"] unsignedLongLongValue];
    }
    
    // if cdn_enabled is in here, we're parsing from the cdn API
    if ([dict objectForKey:@"cdn_enabled"]) {
        container.hasEverBeenCDNEnabled = YES;
        container.cdnEnabled = [[dict objectForKey:@"cdn_enabled"] boolValue];
        container.ttl = [[dict objectForKey:@"ttl"] intValue];
        container.cdnURL = [dict objectForKey:@"cdn_uri"];
        container.referrerACL = [dict objectForKey:@"referrer_acl"];
        container.useragentACL = [dict objectForKey:@"useragent_acl"];
        container.logRetention = [[dict objectForKey:@"log_retention"] boolValue];
    }

    return container;
}

#pragma mark -
#pragma mark Display

+(NSString *)humanizedBytes:(unsigned long long)bytes {    
	NSString *result;	
	if (bytes >= 1024000000) {
		result = [NSString stringWithFormat:@"%.2f GiB", bytes / 1024000000.0];
	} else if (bytes >= 1024000) {
		result = [NSString stringWithFormat:@"%.2f MiB", bytes / 1024000.0];
	} else if (bytes >= 1024) {
		result = [NSString stringWithFormat:@"%.2f KiB", bytes / 1024.0];
    } else if (bytes == 1) {
        result = @"1 byte";
	} else {
		result = [NSString stringWithFormat:@"%llu bytes", bytes];
    }
	return result;
}

-(NSString *)humanizedBytes {
    return [Container humanizedBytes:self.bytes];
}

-(NSString *)humanizedCount {
	NSString *noun = NSLocalizedString(@"objects", @"objects");
	if (self.count == 1) {
		noun = NSLocalizedString(@"object", @"object");
	}
	return [NSString stringWithFormat:@"%i %@", self.count, noun];
}


-(NSString *)humanizedSize {
	return [NSString stringWithFormat:@"%@, %@", [self humanizedCount], [self humanizedBytes]];
}

#pragma mark -
#pragma mark Comparison

// flavors should be sorted by RAM instead of name
- (NSComparisonResult)compare:(Container *)aContainer {
    return [self.name compare:aContainer.name];
}

#pragma mark -
#pragma mark Memory Management

-(void) dealloc {
	[name release];
    [rootFolder release];
	[super dealloc];
}

@end
