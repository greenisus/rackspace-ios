//
//  ImageTests.m
//  OpenStack
//
//  Created by Mike Mayo on 10/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "JSONTests.h"
#import "JSON.h"
#import "Image.h"
#import "Server.h"


@implementation JSONTests

- (void)testImageParsing {

    NSString *jsonTest = @"{\"images\":[{\"id\":29,\"status\":\"ACTIVE\",\"updated\":\"2010-01-26T12:07:32-06:00\",\"name\":\"Windows Server 2003 R2 SP2 x86\"},{\"id\":41,\"status\":\"ACTIVE\",\"updated\":\"2010-09-20T09:08:35-05:00\",\"name\":\"Oracle EL JeOS Release 5 Update 3\"},{\"id\":62,\"status\":\"ACTIVE\",\"updated\":\"2010-09-27T10:58:11-05:00\",\"name\":\"Red Hat Enterprise Linux 5.5\"},{\"id\":53,\"status\":\"ACTIVE\",\"updated\":\"2010-06-27T20:13:08-05:00\",\"name\":\"Fedora 13 (Goddard)\"},{\"id\":187811,\"status\":\"ACTIVE\",\"updated\":\"2009-12-16T01:02:17-06:00\",\"name\":\"CentOS 5.4\"},{\"id\":4,\"status\":\"ACTIVE\",\"updated\":\"2009-08-26T14:59:52-05:00\",\"name\":\"Debian 5.0 (lenny)\"},{\"id\":10,\"status\":\"ACTIVE\",\"updated\":\"2009-08-26T14:59:54-05:00\",\"name\":\"Ubuntu 8.04.2 LTS (hardy)\"},{\"id\":17,\"status\":\"ACTIVE\",\"updated\":\"2009-12-15T15:43:59-06:00\",\"name\":\"Fedora 12 (Constantine)\"},{\"id\":23,\"status\":\"ACTIVE\",\"updated\":\"2010-01-26T12:05:53-06:00\",\"name\":\"Windows Server 2003 R2 SP2 x64\"},{\"id\":24,\"status\":\"ACTIVE\",\"updated\":\"2010-01-26T12:07:04-06:00\",\"name\":\"Windows Server 2008 SP2 x64\"},{\"id\":49,\"status\":\"ACTIVE\",\"updated\":\"2010-05-04T08:58:18-05:00\",\"name\":\"Ubuntu 10.04 LTS (lucid)\"},{\"id\":14362,\"status\":\"ACTIVE\",\"updated\":\"2009-11-06T05:09:40-06:00\",\"name\":\"Ubuntu 9.10 (karmic)\"},{\"id\":8,\"status\":\"ACTIVE\",\"updated\":\"2009-12-07T16:22:14-06:00\",\"name\":\"Ubuntu 9.04 (jaunty)\"},{\"id\":31,\"status\":\"ACTIVE\",\"updated\":\"2010-01-26T12:07:44-06:00\",\"name\":\"Windows Server 2008 SP2 x86\"},{\"id\":51,\"status\":\"ACTIVE\",\"updated\":\"2010-05-21T00:01:43-05:00\",\"name\":\"CentOS 5.5\"},{\"id\":14,\"status\":\"ACTIVE\",\"updated\":\"2009-12-15T15:37:22-06:00\",\"name\":\"Red Hat Enterprise Linux 5.4\"},{\"id\":19,\"status\":\"ACTIVE\",\"updated\":\"2009-12-15T15:43:39-06:00\",\"name\":\"Gentoo 10.1\"},{\"id\":28,\"status\":\"ACTIVE\",\"updated\":\"2010-01-26T12:07:17-06:00\",\"name\":\"Windows Server 2008 R2 x64\"},{\"id\":55,\"status\":\"ACTIVE\",\"updated\":\"2010-06-29T05:21:55-05:00\",\"name\":\"Arch 2010.05\"},{\"id\":40,\"status\":\"ACTIVE\",\"updated\":\"2010-09-19T21:07:45-05:00\",\"name\":\"Oracle EL Server Release 5 Update 4\"},{\"progress\":100,\"id\":3231266,\"status\":\"ACTIVE\",\"created\":\"2010-04-24T21:48:58-05:00\",\"updated\":\"2010-04-24T21:54:39-05:00\",\"name\":\"fedora12-image\",\"serverId\":193115}]}";
    
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:jsonTest] objectForKey:@"images"];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        Image *image = [Image fromJSON:dict];
        [objects addObject:image];
        
    }
    [parser release];
    STAssertTrue([objects count] == 21, @"There should be 21 images parsed.  Got %i instead.", [objects count]);
    
    Image *image = [objects objectAtIndex:0];
    STAssertTrue(image.identifier == 29, @"Image ID should be 29.  Got %i instead.", image.identifier);
    STAssertTrue([image.status isEqualToString:@"ACTIVE"], @"Image status should be ACTIVE.  Got %@", image.status);
    STAssertNotNil(image.updated, @"Image updated date should not be nil.");
    STAssertTrue([image.name isEqualToString:@"Windows Server 2003 R2 SP2 x86"], @"Image name should be 'Windows Server 2003 R2 SP2 x86'.  Got '%@'.", image.name);
    
}

- (void)testServerParsing {
}

@end
