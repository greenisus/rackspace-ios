//
//  RSTextFieldCell.h
//  RSCustomViews
//
//  Created by Mike Mayo on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RSTextFieldCell : UITableViewCell {
    UITextField *textField;
    UIModalPresentationStyle modalPresentationStyle;
}

@property (readonly, retain) UITextField *textField;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;

@end
