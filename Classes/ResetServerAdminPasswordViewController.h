//
//  ResetServerAdminPasswordViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 2/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ServerActionViewController.h"

@class ServerViewController;

@interface ResetServerAdminPasswordViewController : ServerActionViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITextField *textField;
	UITextField *confirmTextField;
}

-(void)saveButtonPressed:(id)sender;
	
@end
