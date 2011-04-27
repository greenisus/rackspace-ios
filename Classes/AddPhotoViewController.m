//
//  AddPhotoViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoViewController.h"
#import "UIViewController+Conveniences.h"
#import "UIColor+MoreColors.h"
#import "Container.h"
#import "ActivityIndicatorView.h"
#import "StorageObject.h"
#import "OpenStackAccount.h"
#import "AccountManager.h"
#import "Container.h"
#import "Folder.h"
#import "FolderViewController.h"

#define kName 0

// give me the option to add a description of the file and the URL - date/time stamped

@implementation AddPhotoViewController

@synthesize image, account, container, folder, folderViewController, isFromCamera;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Photo";
    [self addSaveButton];
    format = @".jpg";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(98.0, 13.0, 400.0, 24.0)];
    } else {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, 13.0, 222.0, 24.0)];
    }    
    nameTextField.delegate = self;
    nameTextField.font = [UIFont systemFontOfSize:17.0];
    nameTextField.textColor = [UIColor value1DetailTextLabelColor];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.textAlignment = UITextAlignmentRight;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;    
    nameTextField.placeholder = [NSString stringWithFormat:@"ios_upload_%.0f", [[NSDate date] timeIntervalSince1970]];    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(41.0, 15.5, 458.0, 18.0)];
    } else {
        formatLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 15.5, 280.0, 18.0)];
    }    
    formatLabel.font = [UIFont systemFontOfSize:17.0];
    formatLabel.textColor = [UIColor value1DetailTextLabelColor];
    formatLabel.backgroundColor = [UIColor clearColor];
    formatLabel.textAlignment = UITextAlignmentRight;
    formatLabel.text = format;
    
    slider = [[UISlider alloc] init];
    slider.value = 0.65;
    
    // move the text field to make room for the numbers label
    CGSize size = [formatLabel.text sizeWithFont:formatLabel.font constrainedToSize:CGSizeMake(280.0, 900.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nameTextField.frame = CGRectMake(98.0, 13.0, 400.0 - size.width, 24.0);
    } else {
        nameTextField.frame = CGRectMake(79.0, 13.0, 222.0 - size.width, 24.0);
    }    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    data = UIImageJPEGRepresentation(image, slider.value);
//    [data retain];
    
    // when saving a camera image as a PNG, it ends up rotated.  i have no idea why and have
    // not been able to successfully rotate the image, so we're only allowing JPEG from the
    // camera for now.  not a big deal, since the iPhone 4 camera is making 8 MB PNG files
    if (isFromCamera) {
        formatSection = -1;
        qualitySection = 1;
    } else {
        formatSection = 1;
        qualitySection = 2;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    qualityActivityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Calculating size..."] text:@"Calculating size..."];
    [qualityActivityIndicatorView addToView:self.view];    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(calculateSize) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([format isEqualToString:@".jpg"]) {
        if (transitioning) {
            return isFromCamera ? 1 : 2;
        } else {
            return isFromCamera ? 2 : 3;
        }
    } else {
        return transitioning ? 3 : 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kName) {
        return 2;
    } else if (section == formatSection) {
        return 2;
    } else if (section == qualitySection) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == qualitySection) {
        return tableView.rowHeight + slider.frame.size.height + 3.0;
    } else {
        return tableView.rowHeight;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == formatSection) {
        return @"JPEG is a lossy format designed for digital photography. PNG is a lossless format that supports transparency.";
    } else if (section == qualitySection) {
        return @"A high quality will produce a better image. A low quality will use less space.";
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView nameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NameCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Name";
        [cell addSubview:nameTextField];
        [cell addSubview:formatLabel];
    }    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView qualityCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"QualityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 280.0, 20.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabel.frame = CGRectMake(41.0, 13.0, 458.0, 20.0);
        }
        textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        textLabel.text = @"Quality";
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:textLabel];
        [textLabel release];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            slider.frame = CGRectMake(41.0, 38.0, 458.0, slider.frame.size.height);
        } else {
            slider.frame = CGRectMake(20.0, 38.0, 280.0, slider.frame.size.height);
        }
        
        [slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderFinished:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:slider];
        qualityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 280.0, 18.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            qualityLabel.frame = CGRectMake(41.0, 14.0, 458.0, 18.0);
        }        
        qualityLabel.font = [UIFont systemFontOfSize:17.0];
        qualityLabel.textColor = [UIColor value1DetailTextLabelColor];
        qualityLabel.backgroundColor = [UIColor clearColor];
        qualityLabel.textAlignment = UITextAlignmentRight;
        [cell addSubview:qualityLabel];
    }
    
    qualityLabel.text = [NSString stringWithFormat:@"%.0f%%", slider.value * 100];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == kName && indexPath.row == 0) {
        return [self tableView:tableView nameCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == qualitySection) {
        return [self tableView:tableView qualityCellForRowAtIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if (indexPath.section == kName) {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [Container humanizedBytes:[data length]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.section == formatSection) {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"JPEG";
                cell.detailTextLabel.text = @"";
                if ([format isEqualToString:@".jpg"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"PNG";
                cell.detailTextLabel.text = @"";
                if ([format isEqualToString:@".png"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else {
            cell.textLabel.text = @"Quality";
            cell.detailTextLabel.text = @"65%";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)updateFormat {
    
    transitioning = YES;
    
    NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:formatSection], [NSIndexPath indexPathForRow:1 inSection:formatSection], nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    transitioning = NO;
    
    if ([format isEqualToString:@".jpg"]) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:qualitySection] withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:qualitySection] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    formatLabel.text = format;
    // move the text field to make room for the numbers label
    CGSize size = [formatLabel.text sizeWithFont:formatLabel.font constrainedToSize:CGSizeMake(280.0, 900.0f)];
    nameTextField.frame = CGRectMake(79.0, 13.0, 222.0 - size.width, 24.0);
    
    qualityActivityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Calculating size..."] text:@"Calculating size..."];
    [qualityActivityIndicatorView addToView:self.view];    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(calculateSize) userInfo:nil repeats:NO];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == formatSection) {
        if (indexPath.row == 0) {
            format = @".jpg";
        } else { //if (indexPath.row == 1) {
            format = @".png";
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(updateFormat) userInfo:nil repeats:NO];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Slider

- (void)calculateSize {
    if ([format isEqualToString:@".jpg"]) {
        [data release];
        data = UIImageJPEGRepresentation(image, slider.value);
        [data retain];
    } else {
        [data release];
        
        if (isFromCamera) {
            // PNG files from the camera need to be rotated
            UIImage *rotatedImage = [[UIImage alloc] initWithCGImage:(CGImageRef)image scale:1.0 orientation:UIImageOrientationLeft];
            data = UIImagePNGRepresentation(rotatedImage);
            [rotatedImage release];
        } else {
            data = UIImagePNGRepresentation(image);
        }
        [data retain];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:kName]] withRowAnimation:UITableViewRowAnimationNone];    
    [qualityActivityIndicatorView removeFromSuperviewAndRelease];
}

- (void)sliderFinished:(id)sender {
    qualityActivityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Calculating size..."] text:@"Calculating size..."];
    [qualityActivityIndicatorView addToView:self.view];    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(calculateSize) userInfo:nil repeats:NO];
}

- (void)sliderMoved:(id)sender {
    qualityLabel.text = [NSString stringWithFormat:@"%.0f%%", slider.value * 100];
}

#pragma mark -
#pragma mark Save Button

- (void)saveButtonPressed:(id)sender {
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Uploading..." withProgress:YES] text:@"Uploading..." withProgress:YES];
    [activityIndicatorView addToView:self.view];

    StorageObject *object = [[StorageObject alloc] init];
    
    if (nameTextField.text && ![nameTextField.text isEqualToString:@""]) {
        object.name = [NSString stringWithFormat:@"%@%@", nameTextField.text, format];
    } else {
        object.name = [NSString stringWithFormat:@"%@%@", nameTextField.placeholder, format];
    }
    object.fullPath = [NSString stringWithFormat:@"%@/%@", [folder fullPath], object.name];
    object.fullPath = [object.fullPath substringFromIndex:1];
    
    if ([format isEqualToString:@".jpg"]) {
        object.contentType = @"image/jpeg";
    } else {
        object.contentType = @"image/png";
    }

    object.data = data;
    object.bytes = [data length];
    
    [self.account.manager writeObject:self.container object:object downloadProgressDelegate:activityIndicatorView.progressView];

    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectSucceeded" object:object queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [activityIndicatorView removeFromSuperviewAndRelease];
            object.data = nil;
            [folder.objects setObject:object forKey:object.name];
            [folderViewController.tableView reloadData];
            [self dismissModalViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
        }];

    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"writeObjectFailed" object:object queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self alert:@"There was a problem uploading this file." request:[notification.userInfo objectForKey:@"request"]];            
            [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
        }];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [image release];
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    [nameTextField release];
    [formatLabel release];
    [slider release];
    [super dealloc];
}


@end

