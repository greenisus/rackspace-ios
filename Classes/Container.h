//
//  Container.h
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>

@class Folder;

@interface Container : NSObject <NSCoding>  {

	// regular container attributes
	NSString *name;
	NSUInteger count;
	unsigned long long bytes;

    // TODO: wade having trouble with directories without markers: user_files/12345/wade.jpg
	
	// CDN container attributes
	BOOL cdnEnabled;
	NSUInteger ttl;
	NSString *cdnURL;
	BOOL logRetention;
	NSString *referrerACL;
	NSString *useragentACL;
    
    // containers don't really have a folder structure, but we're going
    // to simulate on by parsing object names
    Folder *rootFolder;

    // we have to use different API calls for CDN enabling for the first time
    // vs CDN enabling later.  this flag will let us know which call to use
    BOOL hasEverBeenCDNEnabled;
}

// regular container attributes
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) unsigned long long bytes;

-(NSString *)humanizedSize;

// CDN container attributes
@property (nonatomic, assign) BOOL cdnEnabled;
@property (nonatomic, assign) NSUInteger ttl;
@property (nonatomic, retain) NSString *cdnURL;
@property (nonatomic, assign) BOOL logRetention;
@property (nonatomic, retain) NSString *referrerACL;
@property (nonatomic, retain) NSString *useragentACL;
@property (nonatomic, retain) Folder *rootFolder;

@property (nonatomic, assign) BOOL hasEverBeenCDNEnabled;

+ (Container *)fromJSON:(NSDictionary *)dict;
+ (NSString *)humanizedBytes:(unsigned long long)bytes;
- (NSString *)humanizedBytes;
- (NSString *)humanizedCount;
- (NSString *)humanizedSize;

@end
