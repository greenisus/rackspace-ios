//
//  AccountSettingsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/14/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountSettingsViewController.h"
#import "OpenStackAccount.h"
#import "Provider.h"
#import "RSTextFieldCell.h"
#import "UIColor+MoreColors.h"

#define kUsername 0
#define kAPIKey 1

@implementation AccountSettingsViewController

@synthesize account;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"API Account Info";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *backgroundContainer = [[UIView alloc] init];
        backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        NSString *logoFilename = @"account-settings-icon-large.png";
        UIImageView *osLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:logoFilename]];
        osLogo.contentMode = UIViewContentModeScaleAspectFit;
        osLogo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            osLogo.alpha = 0.3;
        }
        [backgroundContainer addSubview:osLogo];
        [osLogo release];
        self.tableView.backgroundView = backgroundContainer;
        [backgroundContainer release];
    }    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [usernameTextField becomeFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ Login", self.account.provider.name];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    }
    
    if (indexPath.row == kUsername) {
        cell.textLabel.text = @"Username";
        usernameTextField = cell.textField;
        usernameTextField.delegate = self;
        usernameTextField.secureTextEntry = NO;
        usernameTextField.returnKeyType = UIReturnKeyNext;
        usernameTextField.text = self.account.username;
        usernameTextField.placeholder = @"username";
    } else if (indexPath.row == kAPIKey) {
        cell.textLabel.text = @"API Key";
        apiKeyTextField = cell.textField;
        apiKeyTextField.secureTextEntry = YES;
        apiKeyTextField.delegate = self;
        apiKeyTextField.returnKeyType = UIReturnKeyDone;
        apiKeyTextField.text = self.account.apiKey;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];    
    if ([textField isEqual:usernameTextField]) {
        [apiKeyTextField becomeFirstResponder];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:usernameTextField]) {
        self.account.username = result;
    } else if ([textField isEqual:apiKeyTextField]) {
        self.account.apiKey = result;
    }
    self.account.authToken = @"";
    self.account.hasBeenRefreshed = NO;
    [self.account persist];
    
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [super dealloc];
}


@end

