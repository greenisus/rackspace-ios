//
//  Object.m
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "StorageObject.h"
#import "ComputeModel.h"
#import "NSObject+NSCoding.h"


@implementation StorageObject

@synthesize name, fullPath, hash, bytes, contentType, lastModified, data, metadata;

#pragma mark -
#pragma mark Serialization

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:fullPath forKey:@"fullPath"];
    [coder encodeObject:hash forKey:@"hash"];
    [coder encodeInt:bytes forKey:@"bytes"];
    [coder encodeObject:contentType forKey:@"contentType"];
    [coder encodeObject:lastModified forKey:@"lastModified"];
    // not persisting data to save space
    [coder encodeObject:metadata forKey:@"metadata"];
     */
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        name = [[coder decodeObjectForKey:@"name"] retain];
        fullPath = [[coder decodeObjectForKey:@"fullPath"] retain];
        hash = [[coder decodeObjectForKey:@"hash"] retain];
        bytes = [coder decodeIntForKey:@"bytes"];
        contentType = [[coder decodeObjectForKey:@"contentType"] retain];
        lastModified = [[coder decodeObjectForKey:@"lastModified"] retain];
        data = [[coder decodeObjectForKey:@"data"] retain];
        metadata = [[coder decodeObjectForKey:@"metadata"] retain];
         */
    }
    return self;
}

#pragma mark -
#pragma mark JSON

+ (StorageObject *)fromJSON:(NSDictionary *)dict {
    
    StorageObject *object = [[[StorageObject alloc] init] autorelease];
    
    object.name = [dict objectForKey:@"name"]; // this may be shortened by folder parsing later
    object.fullPath = [dict objectForKey:@"name"];
    object.hash = [dict objectForKey:@"hash"];
    object.bytes = [[dict objectForKey:@"bytes"] intValue];
    object.contentType = [dict objectForKey:@"content_type"];
    object.lastModified = [ComputeModel dateFromString:[dict objectForKey:@"last_modified"]];
    
    return object;
}

#pragma mark -
#pragma mark Presentation

-(NSString *)humanizedBytes {
	NSString *result;	
	if (self.bytes >= 1024000000) {
		result = [NSString stringWithFormat:@"%.2f GiB", self.bytes / 1024000000.0];
	} else if (self.bytes >= 1024000) {
		result = [NSString stringWithFormat:@"%.2f MiB", self.bytes / 1024000.0];
	} else if (self.bytes >= 1024) {
		result = [NSString stringWithFormat:@"%.2f KiB", self.bytes / 1024.0];
	} else {
		result = [NSString stringWithFormat:@"%i bytes", self.bytes];
	}
	return result;
}

- (BOOL)isPlayableMedia {
    
    // check file extension
    NSString *extensionPattern = @"^.+\\.((mov)|(m4a)|(mp3)|(wav)|(aiff)|(aac)|(aif)|(aifc)|(amr)|(caf)|(m2a)|(m4p)|(mp4)|(mpv)|(3gp))$";
    NSRegularExpression *extensionRegex = [NSRegularExpression regularExpressionWithPattern:extensionPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger matches = [extensionRegex numberOfMatchesInString:self.name options:0 range:NSMakeRange(0, [self.name length])];

    // check content type
    NSString *contentTypePattern = @"^(video|audio)/";
    NSRegularExpression *contentTypeRegex = [NSRegularExpression regularExpressionWithPattern:contentTypePattern options:NSRegularExpressionCaseInsensitive error:nil];
    matches += [contentTypeRegex numberOfMatchesInString:self.contentType options:0 range:NSMakeRange(0, [self.contentType length])];
    
    return matches > 0;
}

- (NSComparisonResult)compare:(StorageObject *)anObject {
    return [self.name caseInsensitiveCompare:anObject.name];
}

#pragma mark -
#pragma mark Memory Management

-(void)dealloc {
	[name release];
    [fullPath release];
	[hash release];
	[contentType release];
	[lastModified release];
	[data release];
	[metadata release];
	[super dealloc];
}

@end
