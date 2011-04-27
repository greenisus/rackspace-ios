//
//  ImageFamilyPickerCell.m
//  OpenStack
//
//  Created by Mike Mayo on 10/23/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ImageFamilyPickerCell.h"
#import "OpenStackAccount.h"
#import "Image.h"

#define kScaleY 1.53061224
#define kScaleX .29109589
#define kPickerX -4.0
#define kPickerY -86.0

#define kImageFamily 3
#define kImages 4

@implementation ImageFamilyPickerCell

@synthesize account, tableView, images, selectedFamily;

- (void)groupImages {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:9];
    NSArray *stringKeys = [NSArray arrayWithObjects:@"ubuntu", @"redhat", @"gentoo", @"centos", @"debian", @"windows", @"arch", @"custom", @"fedora", nil];
    
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
            }
        }
    }
    
    images = [[NSDictionary alloc] initWithDictionary:dict];
    [dict release];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier account:(OpenStackAccount *)openStackAccount tableView:(UITableView *)aTableView {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        self.account = openStackAccount;
        self.tableView = aTableView;
        selectedFamily = @"ubuntu";
        [self groupImages];
        
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(kPickerX, kPickerY, 320.0, 320.0)];
        picker.delegate = self;
        picker.dataSource = self;
        picker.showsSelectionIndicator = NO;
        
        //Resize the picker, rotate it so that it is horizontal and set its position
        CGAffineTransform rotate = picker.transform;
        rotate = CGAffineTransformRotate(rotate, 4.71238898);
        rotate = CGAffineTransformScale(rotate, kScaleX, kScaleY);
        CGAffineTransform t0 = CGAffineTransformMakeTranslation(3, 22.5);
        picker.transform = CGAffineTransformConcat(rotate,t0);
        [self addSubview:picker];
        
        // place a mask over the picker to hide the dark outlined area
        UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_picker_mask.png"]];
        mask.userInteractionEnabled = NO;
        //mask.opaque = YES; //for performance
        mask.frame = CGRectMake(0.0, 0.0, 320.0, 87.0);
        [self addSubview:mask];
        [self bringSubviewToFront:mask];
        [mask release];        
        [picker release];
        
        
    }
    return self;
}

#pragma mark -
#pragma mark Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 9;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        selectedFamily = @"ubuntu";
    } else if (row == 1) {
        selectedFamily = @"redhat";
    } else if (row == 2) {
        selectedFamily = @"gentoo";
    } else if (row == 3) {
        selectedFamily = @"windows";
    } else if (row == 4) {
        selectedFamily = @"debian";
    } else if (row == 5) {
        selectedFamily = @"centos";
    } else if (row == 6) {
        selectedFamily = @"arch";
    } else if (row == 7) {
        selectedFamily = @"fedora";
    } else {
        selectedFamily = @"custom";
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kImages] withRowAnimation:UITableViewRowAnimationFade];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kImageFamily] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *viewForRow = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 94)] autorelease];
    
    NSString *filename = @"";
    NSString *family = @"";
    
    if (row == 0) {
        filename = @"ubuntu-icon.png";
        family = @"Ubuntu";
    } else if (row == 1) {
        filename = @"redhat-icon.png";
        family = @"Red Hat";
    } else if (row == 2) {
        filename = @"gentoo-icon.png";
        family = @"Gentoo";
    } else if (row == 3) {
        filename = @"windows-icon.png";
        family = @"Windows";
    } else if (row == 4) {
        filename = @"debian-icon.png";
        family = @"Debian";
    } else if (row == 5) {
        filename = @"centos-icon.png";
        family = @"CentOS";
    } else if (row == 6) {
        filename = @"arch-icon.png";
        family = @"Arch";
    } else if (row == 7) {
        filename = @"fedora-icon.png";
        family = @"Fedora";
    } else {
        filename = @"openstack_icon.png";
        family = @"Custom";
    }
    
    
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
    
    img.frame = CGRectMake(86.0, -30.0, 110.0, 110.0);
    img.opaque = YES;
    [viewForRow addSubview:img];
    [img release];
    
    UILabel *label;
    
    UIFont *font = [UIFont boldSystemFontOfSize:20.0];
    
    label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 90, 278, 35)] autorelease];
    
    label.text = family;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    [viewForRow addSubview:label];
    
    //CGAffineTransform rotate = CGAffineTransformMakeRotation(1.57);  
    //[viewForRow setTransform:rotate]; 
    
    CGAffineTransform rotate = viewForRow.transform;
    rotate = CGAffineTransformRotate(rotate, -4.71238898);
    rotate = CGAffineTransformScale(rotate, kScaleX, kScaleY);
    
    
    CGAffineTransform t0 = CGAffineTransformMakeTranslation(3, 22.5);
    viewForRow.transform = CGAffineTransformConcat(rotate,t0);
    
    return viewForRow;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [account release];
    [tableView release];
    [images release];
    [selectedFamily release];
    [super dealloc];
}


@end
