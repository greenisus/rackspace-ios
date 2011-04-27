//
//  ChefValidationKeyViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 11/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>


@interface ChefValidationKeyViewController : UITableViewController <UITextFieldDelegate> {
    BOOL usingOpscodePlatform;
    NSString *organization;
    NSDictionary *pemFiles;
    NSArray *sortedPemFilenames;
    UITextField *textField;
    NSIndexPath *selectedIndexPath;
    
    // TODO: hidden UITextView, get rid of the string manipulation
}

@end
