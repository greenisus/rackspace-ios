//
//  TextViewCell.m
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "TextViewCell.h"


@implementation TextViewCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		
		// place the text field where the text label belongs	
		CGRect rect = CGRectInset(self.contentView.bounds, 15.0, 2.0);
        //rect.size.width += 100;
        //rect.size.height += 5; // make slightly taller to not clip the bottom of text
        
		self.textView = [[UITextView alloc] initWithFrame:rect];
        self.textView.editable = NO;
        self.textView.font = [UIFont fontWithName:@"Courier New" size:self.textView.font.pointSize];
        self.textView.userInteractionEnabled = NO;
		//self.textView.returnKeyType = UIReturnKeyDone;
		//self.textView.adjustsFontSizeToFitWidth = NO;
		//self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
		//self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		//self.textView.font = [UIFont fontWithName:self.textView.font.fontName size:17.0];
        //self.textView.textColor = [UIColor colorWithRed:0.098 green:0.298 blue:0.498 alpha:1.0];
		[self addSubview:self.textView];		
    }
    return self;
}


//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//    if (selected) {
//        self.textView.textColor = [UIColor whiteColor];
//    } else {
//        self.textView.textColor = [UIColor blackColor];
//    }
//}


- (void)dealloc {
    [textView release];
    [super dealloc];
}

@end
