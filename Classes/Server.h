//
//  Server.h
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@class Image, Flavor, BackupSchedule;

@interface Server : ComputeModel <NSCoding> {
    
    // progress from 0-100 for the current or last action
    NSInteger progress;
        
    NSInteger imageId;
    NSInteger flavorId;
    NSString *status;
    
    // unique ID for the host machine
    NSString *hostId;
    
    // "public" and "private" IP addresses
    NSDictionary *addresses;
    
    NSDictionary *metadata;
    
    Image *image;
    Flavor *flavor;
    
    NSString *rootPassword;
    
    // user configured URLs that are associated with the server
    NSMutableDictionary *urls;
        
    // personality is for file injection.  keys are the path, and values are file contents
    NSDictionary *personality;
    
    BackupSchedule *backupSchedule;
    
}

@property (assign) NSInteger progress;
@property (assign) NSInteger imageId;
@property (assign) NSInteger flavorId;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *hostId;
@property (nonatomic, retain) NSDictionary *addresses;
@property (nonatomic, retain) NSDictionary *metadata;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) Flavor *flavor;
@property (nonatomic, retain) NSMutableDictionary *urls;
@property (nonatomic, retain) NSDictionary *personality;
@property (nonatomic, retain) BackupSchedule *backupSchedule;
@property (nonatomic, retain) NSString *rootPassword;

- (id)initWithJSONDict:(NSDictionary *)dict;

+ (Server *)fromJSON:(NSDictionary *)jsonDict;
- (NSString *)toJSON;
- (BOOL)shouldBePolled;

@end
