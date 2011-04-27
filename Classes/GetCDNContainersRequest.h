//
//  GetCDNContainersRequest.h
//  OpenStack
//
//  Created by Mike Mayo on 12/27/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackRequest.h"


@interface GetCDNContainersRequest : OpenStackRequest {

}

+ (GetCDNContainersRequest *)request:(OpenStackAccount *)account;

@end
