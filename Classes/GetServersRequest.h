//
//  GetServersRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/24/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"

@class OpenStackAccount;

@interface GetServersRequest : OpenStackRequest {

}

+ (GetServersRequest *)request:(OpenStackAccount *)account;

@end
