//
//  GetObjectsRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"

@class OpenStackAccount, Container;

@interface GetObjectsRequest : OpenStackRequest {
    Container *container;
}

@property (nonatomic, retain) Container *container;

+ (GetObjectsRequest *)request:(OpenStackAccount *)account container:(Container *)container;

@end
