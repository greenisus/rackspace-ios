//
//  AddFileViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFileViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVCaptureDevice.h>
#import "UIViewController+Conveniences.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Container.h"
#import "Folder.h"
#import "FolderViewController.h"
#import "StorageObject.h"
#import "ActivityIndicatorView.h"
#import "AddPhotoViewController.h"
#import "UploadGenericFileViewController.h"
#import "AddTextFileViewController.h"


@implementation AddFileViewController

@synthesize account, container, folder, folderViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Camera

- (void)assessDeviceAbilities {
    
    sectionOffset = 0;
    
    // let's determine what the camera (if there is one) is capable of doing    
    
    hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];    
    if (hasCamera) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        for (NSString *type in mediaTypes) {
            if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
                canRecordVideo = YES;
                break;
            }
        }
        cameraRow = 0;
    } else {
        cameraRow = -1;
    }
    
    hasPhotoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (hasPhotoLibrary) {        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        for (NSString *type in mediaTypes) {
            if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
                hasVideoInLibrary = YES;
                break;
            }
        }
        if (hasCamera) {
            libraryRow = 1;
        } else {
            libraryRow = 0;
        }
    } else {
        libraryRow = -1;
    }
    
    cameraSection = (hasPhotoLibrary || hasCamera) ? sectionOffset++ : -1;
    
    canRecordAudio = NO; //[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count] > 0;
    audioSection = canRecordAudio ? sectionOffset++ : -1;
    textFileSection = sectionOffset++;
    iTunesSection = -1; //sectionOffset++;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add File";
    [self assessDeviceAbilities];
    popover = nil;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionOffset;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == cameraSection) {
        if (hasPhotoLibrary && hasCamera) {
            return 2;
        } else if (hasPhotoLibrary || hasCamera) {
            return 1;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    
    if (indexPath.section == cameraSection) {
        
        if (indexPath.row == cameraRow) {
            if (hasCamera && canRecordVideo) {
                cell.textLabel.text = @"Camera Photo or Video";
            } else {
                cell.textLabel.text = @"Camera Photo";
            }
            cell.imageView.image = [UIImage imageNamed:@"camera-icon.png"];
        } else if (indexPath.row == libraryRow) {
            if (hasPhotoLibrary && hasVideoInLibrary) {
                cell.textLabel.text = @"Library Photo or Video";
            } else {
                cell.textLabel.text = @"Library Photo";
            }
            cell.imageView.image = [UIImage imageNamed:@"photo-icon.png"];
        }
    } else if (indexPath.section == textFileSection) {
        cell.textLabel.text = @"Text File";

        NSString *emptyPath = [[NSBundle mainBundle] pathForResource:@"empty-file" ofType:@""];
        UIDocumentInteractionController *udic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:emptyPath]];
        cell.imageView.image = [udic.icons objectAtIndex:0]; //[UIImage imageNamed:@"file-icon.png"];        
    } else if (indexPath.section == audioSection) {
        cell.textLabel.text = @"Record Audio";
        cell.imageView.image = [UIImage imageNamed:@"audio-icon.png"];
    } else if (indexPath.section == iTunesSection) {
        cell.textLabel.text = @"File Synced with iTunes";
        cell.imageView.image = [UIImage imageNamed:@"sync-icon.png"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == cameraSection) {
        
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        if (indexPath.row == cameraRow) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (indexPath.row == libraryRow) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
            if (popover) {
                [popover release];
            }
            popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            popover.delegate = self;
            
            UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
            CGRect rect = cell.frame;
            rect.origin.x += 150.0;
            
            [popover presentPopoverFromRect:rect inView:tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];        
        } else {
            [self.navigationController presentModalViewController:imagePicker animated:YES];
        }
        [imagePicker release];
    } else if (indexPath.section == textFileSection) {
        AddTextFileViewController *vc = [[AddTextFileViewController alloc] initWithNibName:@"AddTextFileViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.folder = self.folder;
        vc.folderViewController = self.folderViewController;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark -
#pragma mark Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
    if (movieURL) {
        UploadGenericFileViewController *vc = [[UploadGenericFileViewController alloc] initWithNibName:@"UploadGenericFileViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.folder = self.folder;
        vc.folderViewController = self.folderViewController;
        vc.data = [NSData dataWithContentsOfURL:movieURL];
        vc.contentTypeEditable = YES;
        vc.format = @".mov";
        vc.contentType = @"video/quicktime";
        [self.navigationController pushViewController:vc animated:NO];
        [vc release];
    } else {
        // it's a photo!
        UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
        AddPhotoViewController *vc = [[AddPhotoViewController alloc] initWithNibName:@"AddPhotoViewController" bundle:nil];
        vc.image = image;
        vc.account = self.account;
        vc.container = self.container;
        vc.folder = self.folder;
        vc.folderViewController = self.folderViewController;
        vc.isFromCamera = (picker.sourceType == UIImagePickerControllerSourceTypeCamera);
        [self.navigationController pushViewController:vc animated:NO];
        [vc release];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popover dismissPopoverAnimated:YES];
    } else {
        [picker dismissModalViewControllerAnimated:YES];    
    }
}

#pragma mark -
#pragma mark Popover Controller Delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:libraryRow inSection:cameraSection] animated:YES];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    if (popover) {
        [popover release];
    }
    [super dealloc];
}


@end

