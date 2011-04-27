//
//  Folder.m
//  OpenStack
//
//  Created by Mike Mayo on 12/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Folder.h"
#import "StorageObject.h"
#import "NSObject+NSCoding.h"


@implementation Folder

@synthesize name, parent, folders, objects;

+ (id)folder {
	Folder *folder = [[[self alloc] init] autorelease];
	folder.folders = [[NSMutableDictionary alloc] init];
	folder.objects = [[NSMutableDictionary alloc] init];
	return folder;
}

#pragma mark -
#pragma mark Serialization

- (id)init {
    if (self = [super init]) {
        self.folders = [[NSMutableDictionary alloc] init];
        self.objects = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
    /*
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:parent forKey:@"parent"];
    [coder encodeObject:folders forKey:@"folders"];
    [coder encodeObject:objects forKey:@"objects"];
     */
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        [self autoDecode:coder];
        /*
        name = [[coder decodeObjectForKey:@"name"] retain];
        parent = [[coder decodeObjectForKey:@"parent"] retain];
        folders = [[coder decodeObjectForKey:@"folders"] retain];
        objects = [[coder decodeObjectForKey:@"objects"] retain];
         */
    }
    return self;
}


- (void)setObjects:(NSMutableDictionary *)objs {
    if (self.objects != objs) {
        [self.objects release];
        
        NSMutableDictionary *folderedFiles = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
        folders = [[NSMutableDictionary alloc] init];

        for (NSString *key in objs) {
            StorageObject *object = [objs objectForKey:key];
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/" options:NSRegularExpressionCaseInsensitive error:nil];            
            NSInteger matches = [regex numberOfMatchesInString:object.name options:0 range:NSMakeRange(0, [object.name length])];

            if (matches > 0) {
                // build up the folder structure
                NSArray *components = [object.name componentsSeparatedByString:@"/"];
                NSString *folderName = [components objectAtIndex:0];                
                object.name = [components lastObject];
                
                for (int i = [components count] - 2; i > 0; i--) {
                    object.name = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:i], object.name];
                }

                if (![folderedFiles objectForKey:folderName]) {
                    [folderedFiles setObject:[[NSMutableDictionary alloc] init] forKey:folderName];
                }

                NSMutableDictionary *files = [folderedFiles objectForKey:folderName];
                [files setObject:object forKey:object.name];
                
            } else if ([object.contentType isEqualToString:@"application/directory"]) {
                Folder *folder = [[Folder alloc] init];
                folder.name = object.name;
                folder.parent = self;
                [self.folders setObject:folder forKey:folder.name];
                [folder release];
            } else {
                // put the files in this folder                
                [files setObject:object forKey:object.name];
            }
        }
        
        // take the foldered files and recursively build the rest of the folder structure
        NSArray *keys = [folderedFiles allKeys];
        for (int i = 0; i < [keys count]; i++) {
            NSString *folderName = [keys objectAtIndex:i];
            NSMutableDictionary *files = [folderedFiles objectForKey:folderName];
            Folder *folder = [[Folder alloc] init];
            folder.name = folderName;
            folder.parent = self;
            folder.objects = files;
            [self.folders setObject:folder forKey:folder.name];
            [folder release];
        }
        
        [folderedFiles release];
        
        objects = files;
    }
}

- (NSArray *)sortedContents {
    NSMutableArray *contents = [[NSMutableArray alloc] initWithArray:[self.folders allValues]];
    [contents addObjectsFromArray:[self.objects allValues]];
    if (!sortedContents || [sortedContents count] != [contents count]) {
        sortedContents = [[NSArray alloc] initWithArray:[contents sortedArrayUsingSelector:@selector(compare:)]];
    }
    [contents release];
    return sortedContents;
}

- (NSComparisonResult)compare:(Folder *)aFolder {
    return [self.name caseInsensitiveCompare:aFolder.name];
}

- (NSString *)fullPath {
    NSString *result = self.name;
    if (parent) {
        result = [NSString stringWithFormat:@"%@/%@", [parent fullPath], self.name];
    }
    if (!result) {
        result = @"";
    }
    return result;
}

-(void)dealloc {
	[name release];
	[parent release];
	[folders release];
	[objects release];
    [sortedContents release];
	[super dealloc];
}

@end
