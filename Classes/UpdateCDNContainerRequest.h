//
//  UpdateCDNContainerRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"

@class Container;

@interface UpdateCDNContainerRequest : OpenStackRequest {
    Container *container;
}

@property (nonatomic, retain) Container *container;

+ (UpdateCDNContainerRequest *)request:(OpenStackAccount *)account container:(Container *)container;

@end
