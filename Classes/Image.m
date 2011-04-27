//
//  Image.m
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Image.h"
#import "NSObject+NSCoding.h"


@implementation Image

@synthesize status, created, updated, canBeLaunched;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeInt:identifier forKey:@"id"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:status forKey:@"status"];
    [coder encodeObject:created forKey:@"created"];
    [coder encodeObject:updated forKey:@"updated"];
    [coder encodeBool:canBeLaunched forKey:@"canBeLaunched"];
    */
}

- (id)initWithCoder:(NSCoder *)coder {
    
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        identifier = [coder decodeIntForKey:@"id"];
        name = [[coder decodeObjectForKey:@"name"] retain];
        status = [[coder decodeObjectForKey:@"status"] retain];
        created = [[coder decodeObjectForKey:@"created"] retain];
        updated = [[coder decodeObjectForKey:@"updated"] retain];
        canBeLaunched = [coder decodeBoolForKey:@"canBeLaunched"];
        */
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (Image *)fromJSON:(NSDictionary *)dict {
    Image *image = [[[Image alloc] initWithJSONDict:dict] autorelease];
    [self autoParse:&image fromJSONDict:dict];
    /*
    image.status = [dict objectForKey:@"status"];
    image.updated = [image dateForKey:@"updated" inDict:dict];
    image.created = [image dateForKey:@"created" inDict:dict];
     */
    return image;
}

#pragma mark -
#pragma mark Logo

- (NSString *)logoPrefix {
	if ([name hasPrefix:@"CentOS"]) {
		return @"centos";
	} else if ([name hasPrefix:@"Gentoo"]) {
		return @"gentoo";
	} else if ([name hasPrefix:@"Debian"]) {
		return @"debian";
	} else if ([name hasPrefix:@"Fedora"]) {
		return @"fedora";
	} else if ([name hasPrefix:@"Ubuntu"]) {
		return @"ubuntu";
	} else if ([name hasPrefix:@"Arch"]) {
		return @"arch";
	} else if ([name hasPrefix:@"Red Hat"]) {
		return @"redhat";
	} else if ([name hasPrefix:@"Windows"]) {
		return @"windows";
	} else {
        return @"custom";
	}
}

#pragma mark -
#pragma mark Comparison

// overriding to handle version numbers in image names to create a natural ordering
- (NSComparisonResult)compare:(ComputeModel *)aComputeModel {
    NSComparisonResult result = NSOrderedSame;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSArray *tokensA = [self.name componentsSeparatedByString:@" "];
    NSArray *tokensB = [aComputeModel.name componentsSeparatedByString:@" "];

    for (int i = 0; (i < [tokensA count] && i < [tokensB count]) && result == NSOrderedSame; i++) {

        NSString *tokenA = [tokensA objectAtIndex:i];
        NSString *tokenB = [tokensB objectAtIndex:i];
        
        // problem: 8.04.2 is not a number, so we need to tokenize again on .
        
        NSArray *versionTokensA = [tokenA componentsSeparatedByString:@"."];
        NSArray *versionTokensB = [tokenB componentsSeparatedByString:@"."];
        
        for (int j = 0; (j < [versionTokensA count] || j < [versionTokensB count]) && result == NSOrderedSame; j++) {
            
            NSString *versionTokenA = [versionTokensA objectAtIndex:j];
            NSString *versionTokenB = [versionTokensB objectAtIndex:j];
            NSNumber *numberA = [formatter numberFromString:versionTokenA];
            NSNumber *numberB = [formatter numberFromString:versionTokenB];
            
            if (numberA && numberB) {
                result = [numberA compare:numberB];
            } else {
                result = [versionTokenA compare:versionTokenB];
            }
        }
        
    }
    [formatter release];
    return result;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [status release];
    [created release];
    [updated release];
    [super dealloc];
}

@end
