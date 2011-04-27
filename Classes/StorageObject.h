//
//  Object.h
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>


@interface StorageObject : NSObject <NSCoding> {
	NSString *name;
    NSString *fullPath;
	NSString *hash;
	NSUInteger bytes;
	NSString *contentType;
	NSDate *lastModified;
	NSData *data;
	NSMutableDictionary *metadata;
}

@property (retain) NSString *name;
@property (retain) NSString *fullPath;
@property (retain) NSString *hash;
@property (assign) NSUInteger bytes;
@property (retain) NSString *contentType;
@property (retain) NSDate *lastModified;
@property (retain) NSData *data;	
@property (retain) NSMutableDictionary *metadata;

- (NSString *)humanizedBytes;
+ (StorageObject *)fromJSON:(NSDictionary *)dict;

- (BOOL)isPlayableMedia;

@end
