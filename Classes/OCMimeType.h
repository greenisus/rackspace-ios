//
//  OCMimeType.h
//  OCMimeType
//
//  A simple class to map mime types to file extensions.
//  Source:
//  http://www.w3schools.com/media/media_mimeref.asp
//
//  Created by Mike Mayo on 1/6/11.
//  Copyright 2011 Mike Mayo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OCMimeType : NSObject {

}

+ (NSString *)mimeTypeForFileExtension:(NSString *)fileExtension;
+ (NSString *)fileExtensionForMimeType:(NSString *)mimeType;

@end
