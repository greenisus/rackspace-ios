//
//  Flavor.h
//  OpenStack
//
//  Created by Mike Mayo on 10/1/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ComputeModel.h"

@interface Flavor : ComputeModel <NSCoding> {
    NSInteger ram;
    NSInteger disk;
}

@property (assign) NSInteger ram;
@property (assign) NSInteger disk;

+ (Flavor *)fromJSON:(NSDictionary *)dict;


@end
