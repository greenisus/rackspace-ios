//
//  SimpleImagePickerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "SimpleImagePickerViewController.h"
#import "OpenStackAccount.h"
#import "Image.h"
#import "UIViewController+Conveniences.h"
#import "ServerViewController.h"
#import "AccountManager.h"

@implementation SimpleImagePickerViewController

@synthesize account, tableView, pickerView, delegate, selectedImageId, mode, serverViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)groupImages {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:9];
    stringKeys = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"ubuntu", @"redhat", @"gentoo", @"centos", @"debian", @"windows", @"arch", @"fedora", @"custom", nil]];
    
    // sort in descending order, since the newest versions are likely the most popular choice
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO selector:@selector(compare:)];
    
    for (int i = 0; i < [stringKeys count]; i++) {
        NSString *stringKey = [stringKeys objectAtIndex:i];
        NSArray *keys = [self.account.images allKeys];
        for (int j = 0; j < [keys count]; j++) {
            Image *image = [self.account.images objectForKey:[keys objectAtIndex:j]];
            if ([[image logoPrefix] isEqualToString:stringKey]) {
                if (![dict objectForKey:stringKey]) {
                    [dict setObject:[[[NSMutableArray alloc] init] autorelease] forKey:stringKey];
                }
                NSMutableArray *keyedImages = [dict objectForKey:stringKey];
                [keyedImages addObject:image];
                [keyedImages sortUsingSelector:@selector(compare:)];
                [keyedImages sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            }
        }        
    }
    
    NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
    
    for (NSString *key in stringKeys) {
        NSMutableArray *keyedImages = [dict objectForKey:key];
        if ([keyedImages count] == 0) {
            [keysToRemove addObject:key];
        }
    }
    
    for (NSString *key in keysToRemove) {
        [stringKeys removeObject:key];
    }
    
    [keysToRemove release];
    [sortDescriptor release];
    images = [[NSDictionary alloc] initWithDictionary:dict];
    [dict release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedFamily = @"ubuntu";
    [self groupImages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (mode == kModeChooseImage) {
        self.navigationItem.title = @"Image";    
    } else {
        self.navigationItem.title = @"Rebuild Server";
        [self addCancelButton];
        [self addSaveButton];
    }
    
    Image *image = [self.account.images objectForKey:[NSNumber numberWithInt:selectedImageId]];
    
    for (int i = 0; i < [stringKeys count]; i++) {
        NSString *stringKey = [stringKeys objectAtIndex:i];
        if ([[image logoPrefix] isEqualToString:stringKey]) {
            [self.pickerView selectRow:i inComponent:0 animated:NO];
        }
    }
    selectedFamily = [image logoPrefix];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize = CGSizeMake(260.0, 9000.0f);
    // pad \n\n to fix layout bug
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //CGFloat result = aTableView.rowHeight;
    NSArray *currentImages = [images objectForKey:selectedFamily];
    Image *image = [currentImages objectAtIndex:indexPath.row];    
    CGFloat result = 22.0 + [self findLabelHeight:image.name font:[UIFont boldSystemFontOfSize:18.0]];
    return MAX(aTableView.rowHeight, result);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[images objectForKey:selectedFamily] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    // Configure the cell...
    NSArray *currentImages = [images objectForKey:selectedFamily];
    Image *image = [currentImages objectAtIndex:indexPath.row];
    cell.textLabel.text = image.name;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-icon.png", [image logoPrefix]]];
    
    if (image.identifier == selectedImageId) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *currentImages = [images objectForKey:selectedFamily];
    Image *image = [currentImages objectAtIndex:indexPath.row];
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];

    if (image) {
        selectedImageId = image.identifier;
        if (delegate && [delegate respondsToSelector:@selector(setNewSelectedImage:)]) {
            [delegate performSelector:@selector(setNewSelectedImage:) withObject:image];
        }
        account.lastUsedImageId = image.identifier;
        [account persist];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:aTableView selector:@selector(reloadData) userInfo:nil repeats:NO];
    
}

#pragma mark -
#pragma mark Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [stringKeys count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {    
    selectedFamily = [stringKeys objectAtIndex:row];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *viewForRow = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)] autorelease];
    
    NSString *filename = @"";
    NSString *family = @"";
    
    if ([[stringKeys objectAtIndex:row] isEqualToString:@"ubuntu"]) {
        filename = @"ubuntu-icon.png";
        family = @"Ubuntu";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"redhat"]) {
        filename = @"redhat-icon.png";
        family = @"Red Hat";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"gentoo"]) {
        filename = @"gentoo-icon.png";
        family = @"Gentoo";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"windows"]) {
        filename = @"windows-icon.png";
        family = @"Windows";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"debian"]) {
        filename = @"debian-icon.png";
        family = @"Debian";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"centos"]) {
        filename = @"centos-icon.png";
        family = @"CentOS";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"arch"]) {
        filename = @"arch-icon.png";
        family = @"Arch";
    } else if ([[stringKeys objectAtIndex:row] isEqualToString:@"fedora"]) {
        filename = @"fedora-icon.png";
        family = @"Fedora";
    } else {
        //filename = @"openstack_icon.png";
        //[UIImage imageNamed:@"cloud-servers-icon.png"]
        filename = @"cloud-servers-icon.png";
        family = @"Other";
    }
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
    img.frame = CGRectMake(10.0, 23.0, 35.0, 35.0);
    img.opaque = YES;
    [viewForRow addSubview:img];
    [img release];
    
    UILabel *label;
    
    UIFont *font = [UIFont boldSystemFontOfSize:20.0];
    
    label = [[[UILabel alloc] initWithFrame:CGRectMake(60.0, 23.0, 278, 35)] autorelease];
    label.text = family;
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    [viewForRow addSubview:label];

    return viewForRow;
}
 
#pragma mark -
#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
    [self.serverViewController showToolbarActivityMessage:@"Rebuilding server..."];
    [self.account.manager rebuildServer:self.serverViewController.server image:[self.account.images objectForKey:[NSNumber numberWithInt:self.selectedImageId]]];
    [self dismissModalViewControllerAnimated:YES];
    [serverViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kRebuild inSection:kActions] animated:YES];
}

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
    if (serverViewController) {
        [serverViewController.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kRebuild inSection:kActions] animated:YES];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [account release];
    [tableView release];
    [pickerView release];
    [delegate release];
    [stringKeys release];
    [serverViewController release];
    [super dealloc];
}

@end