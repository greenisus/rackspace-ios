//
//  RSTextFieldCell.m
//  RSCustomViews
//
//  Created by Mike Mayo on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSTextFieldCell.h"


@implementation RSTextFieldCell

@synthesize textField, modalPresentationStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        textField = [[UITextField alloc] initWithFrame:self.detailTextLabel.frame];
        textField.textAlignment = self.detailTextLabel.textAlignment;
        textField.returnKeyType = UIReturnKeyDone;
        textField.backgroundColor = [UIColor clearColor];
		textField.adjustsFontSizeToFitWidth = NO;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
        if (style == UITableViewCellStyleValue1) {
            textField.font = [UIFont systemFontOfSize:17.0];
        } else if (style == UITableViewCellStyleValue2) {
            textField.font = [UIFont boldSystemFontOfSize:15.0];
        }
        
        textField.textColor = self.detailTextLabel.textColor;        
        [self addSubview:textField];
        
        self.detailTextLabel.textColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.highlightedTextColor = [UIColor clearColor];
        self.detailTextLabel.text = @"Using a very long string here to make sure that the UILabel is rendered at the maximum width so we can copy it for the UITextField.";        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGRect aRect = self.detailTextLabel.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (modalPresentationStyle == UIModalPresentationFormSheet) {
            textField.frame = CGRectMake(aRect.origin.x + 31.0, aRect.origin.y + 1.0, aRect.size.width, aRect.size.height);
        } else {
            textField.frame = CGRectMake(aRect.origin.x + 45.0, aRect.origin.y + 1.0, aRect.size.width, aRect.size.height);
        }
    } else {
        textField.frame = CGRectMake(aRect.origin.x + 10.0, aRect.origin.y + 1.0, aRect.size.width, aRect.size.height);
    }
    
    // this isn't generic.  this is for text decoration on the end of the textField
    if (self.accessoryView) {
        aRect = textField.frame;
        aRect.origin.x += 9.0;
        textField.frame = aRect;
    }
    
    textField.contentStretch = self.detailTextLabel.contentStretch;
    textField.backgroundColor = [UIColor clearColor];
    textField.transform = self.detailTextLabel.transform;
    textField.clipsToBounds = self.detailTextLabel.clipsToBounds;
    textField.clearsContextBeforeDrawing = self.detailTextLabel.clearsContextBeforeDrawing;
    textField.contentMode = self.detailTextLabel.contentMode;
    textField.autoresizingMask = self.detailTextLabel.autoresizingMask;
    textField.autoresizesSubviews = YES;
    textField.font = self.detailTextLabel.font;
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}

@end
