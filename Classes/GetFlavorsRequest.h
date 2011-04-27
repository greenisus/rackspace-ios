//
//  GetFlavorsRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"

@class OpenStackAccount;

@interface GetFlavorsRequest : OpenStackRequest {

}

+ (GetFlavorsRequest *)request:(OpenStackAccount *)account;

@end

