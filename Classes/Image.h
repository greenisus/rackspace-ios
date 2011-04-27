//
//  Image.h
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"


@interface Image : ComputeModel <NSCoding> {
    NSString *status;
    NSDate *created;
    NSDate *updated;
    
    // images from GET /images can be used to make new servers, but the API
    // doesn't provide any sort of flag for this, so we'll store it ourselves
    BOOL canBeLaunched;
}

@property (retain) NSString *status;
@property (retain) NSDate *created;
@property (retain) NSDate *updated;
@property (assign) BOOL canBeLaunched;

+ (Image *)fromJSON:(NSDictionary *)dict;

// returns part of the name of the logo (ex: "ubuntu")
// used to look up images for views
- (NSString *)logoPrefix;

@end
