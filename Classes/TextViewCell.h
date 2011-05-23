//
//  TextViewCell.h
//  OpenStack
//
//  Created by Mike Mayo on 10/11/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>


@interface TextViewCell : UITableViewCell {
    UITextView *textView;
}

@property (nonatomic, retain) UITextView *textView;

@end
