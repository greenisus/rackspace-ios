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

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fullPath;
@property (nonatomic, retain) NSString *hash;
@property (nonatomic, assign) NSUInteger bytes;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSDate *lastModified;
@property (nonatomic, retain) NSData *data;	
@property (nonatomic, retain) NSMutableDictionary *metadata;

- (NSString *)humanizedBytes;
+ (StorageObject *)fromJSON:(NSDictionary *)dict;

- (BOOL)isPlayableMedia;

@end
