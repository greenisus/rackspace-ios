//
//  Folder.h
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

// there isn't really a folder resource in the API.  this is an
// abstraction to simulate folders based on object names with
// slashes in them.
// example: MyContainer has the following files:
// 1. test.txt
// 2. folder/abc.txt
// 3. folder/def.txt
// In this case, there would be a folder object for files 2 and 3

@interface Folder : NSObject <NSCoding> {
	NSString *name;
	Folder *parent;
	NSMutableDictionary *folders;
	NSMutableDictionary *objects;
    NSArray *sortedContents;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) Folder *parent;
@property (nonatomic, retain) NSMutableDictionary *folders;
@property (nonatomic, retain) NSMutableDictionary *objects;
@property (readonly, retain) NSArray *sortedContents;

+ (id)folder;
- (NSArray *)sortedContents;
- (NSString *)fullPath;

@end
