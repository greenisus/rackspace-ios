//
//  Server.m
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Server.h"
#import "Base64.h"
#import "NSObject+SBJSON.h"
#import "Flavor.h"
#import "Image.h"
#import "OpenStackAccount.h"
#import "NSObject+NSCoding.h"


@implementation Server

@synthesize progress, imageId, flavorId, status, hostId, addresses, metadata, image, flavor, urls, personality, backupSchedule, rootPassword;


// TODO: getter/setter for rootPassword should use Keychain class
// TODO: generate uuid for servers.  key password on uuid

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder: (NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        [self autoDecode:coder];
    }
    
    return self;
}

#pragma mark -
#pragma mark JSON

+ (Server *)fromJSON:(NSDictionary *)dict {
    Server *server = [[[Server alloc] initWithJSONDict:dict] autorelease];    
    [self autoParse:&server fromJSONDict:dict];
    return server;
}

- (NSString *)toJSON {
    NSString *json = @"{ \"server\": { ";
    
    if (self.name && ![@"" isEqualToString:self.name]) {
        json = [json stringByAppendingString:[NSString stringWithFormat:@"\"name\": \"%@\", ", self.name]];
    }

    json = [json stringByAppendingString:[NSString stringWithFormat:@"\"flavorId\": %i, \"imageId\": %i ", self.flavorId, self.imageId]];

    if (self.metadata && [self.metadata count] > 0) {
        json = [json stringByAppendingString:[NSString stringWithFormat:@", \"metadata\": %@", [self.metadata JSONRepresentation]]];
    }
    
    if (self.personality && [self.personality count] > 0) {
        json = [json stringByAppendingString:@", \"personality\": [ "];

        NSArray *paths = [self.personality allKeys];
        for (int i = 0; i < [paths count]; i++) {
            NSString *path = [paths objectAtIndex:i];
            json = [json stringByAppendingString:[NSString stringWithFormat:@"{ \"path\": \"%@\", \"contents\": \"%@\" }", path, [Base64 encode:[[self.personality objectForKey:path] dataUsingEncoding:NSUTF8StringEncoding]]]];
            if (i < [paths count] - 1) {
                json = [json stringByAppendingString:@", "];
            }
        }
        json = [json stringByAppendingString:@" ]"];
        
    }
    
    json = [json stringByAppendingString:@"}}"];
    
    return json;
}

#pragma mark -
#pragma mark Build

- (BOOL)shouldBePolled {
	return ([self.status isEqualToString:@"BUILD"] || [self.status isEqualToString:@"UNKNOWN"] || [self.status isEqualToString:@"RESIZE"] || [self.status isEqualToString:@"QUEUE_RESIZE"] || [self.status isEqualToString:@"PREP_RESIZE"] || [self.status isEqualToString:@"REBUILD"] || [self.status isEqualToString:@"REBOOT"] || [self.status isEqualToString:@"HARD_REBOOT"]);
}

#pragma mark -
#pragma mark Setters

- (void)setFlavor:(Flavor *)aFlavor {
    if (aFlavor) {
        flavor = aFlavor;
        self.flavorId = self.flavor.identifier;
        [flavor retain];
    }
}

- (Image *)image {
    if (!image) {
        for (OpenStackAccount *account in [OpenStackAccount accounts]) {
            Image *i = [account.images objectForKey:[NSNumber numberWithInt:self.imageId]];
            if (i) {
                image = i;
                break;
            }
        }
    }
    return image;
}

- (void)setImage:(Image *)anImage {
    if (anImage) {
        image = anImage;
        self.imageId = self.image.identifier;
        [image retain];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [status release];
    [hostId release];
    [addresses release];
    [metadata release];
    [image release];
    [flavor release];
    [urls release];
    [personality release];
    [backupSchedule release];
    [rootPassword release];
    [super dealloc];
}

@end
