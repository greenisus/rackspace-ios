//
//  PasscodeViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/26/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "PasscodeViewController.h"
#import "UIViewController+Conveniences.h"
#import "UIColor+MoreColors.h"
#import "Keychain.h"
#import "PasscodeLockViewController.h"
#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Archiver.h"
#import "RootViewController.h"
#import "OpenStackAccount.h"
#import "APILogger.h"
#import "AccountHomeViewController.h"
#import "OpenStackAppDelegate.h"


@implementation PasscodeViewController

@synthesize mode, passcodeLockViewController, settingsViewController, rootViewController, accountHomeViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITextField *)allocAndInitPasscodeTextField {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(29.0, 13.0, 271.0, 24.0)];
    textField.text = @"";
    textField.textColor = [UIColor value1DetailTextLabelColor];
    textField.secureTextEntry = YES;
    textField.delegate = self;
    
    textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    
    return textField;
}

- (void)addNextButton {
    if (!simplePasscodeOn) {
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonPressed:)];
        self.navigationItem.rightBarButtonItem = nextButton;
        [nextButton release];
    }
}

- (void)addDoneButton {
    if (!simplePasscodeOn) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
}

- (void)incrementAndShowFailedAttemptsLabel {
    enterPasscodeTextField.text = @"";
    if (simplePasscodeOn) {
        for (int i = 0; i < 4; i++) {
            [[[squares objectAtIndex:tableIndex] objectAtIndex:i] setImage:[UIImage imageNamed:@"passcode_square_empty.png"]];
        }    
    }
    
    failedAttemptsCount += 1;
    if (failedAttemptsCount == 1) {
        failedAttemptsLabel.text = @"1 Failed Passcode Attempt";
    } else {
        failedAttemptsLabel.text = [NSString stringWithFormat:@"%i Failed Passcode Attempts", failedAttemptsCount];
    }
    CGSize size = [failedAttemptsLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0]];
    failedAttemptsView.frame = CGRectMake((viewWidth - (size.width + 36.0)) / 2, 147.5, size.width + 36.0, size.height + 10.0);
    failedAttemptsLabel.frame = CGRectMake((viewWidth - (size.width + 36.0)) / 2, 147.5, size.width + 36.0, size.height + 10.0); 
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = failedAttemptsView.bounds;        
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.714 green:0.043 blue:0.043 alpha:1.0] CGColor], 
                       (id)[[UIColor colorWithRed:0.761 green:0.192 blue:0.192 alpha:1.0] CGColor], nil];
    [failedAttemptsView.layer insertSublayer:gradient atIndex:0];
    failedAttemptsView.layer.masksToBounds = YES;
    
    failedAttemptsLabel.hidden = NO;
    failedAttemptsView.hidden = NO;
    
    if (failedAttemptsCount == 10 && eraseData) {
        [Archiver deleteEverything];
        [APILogger eraseAllLogs];
        [OpenStackAccount persist:[NSMutableArray array]];        
        if ([Keychain setString:@"NO" forKey:@"passcode_lock_passcode_on"]) {
            [Keychain setString:@"" forKey:@"passcode_lock_passcode"];
        }        
        [self dismissModalViewControllerAnimated:YES];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [UIView beginAnimations:@"fadeIn" context:nil];
            [UIView setAnimationDelay:0.25];
            [UIView setAnimationDuration:0.5];
            OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
            for (UIViewController *svc in app.splitViewController.viewControllers) {
                svc.view.alpha = 1.0;
            }
            [UIView commitAnimations];
        }
        
        [self alert:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted."];
        if (self.rootViewController) {
            [self.rootViewController.navigationController popToRootViewControllerAnimated:NO];
            [self.rootViewController.tableView reloadData];
        }
    }
    
}

- (void)moveToNextTableView {
    tableIndex += 1;
    UITableView *oldTableView = [tableViews objectAtIndex:tableIndex - 1];
    UITableView *newTableView = [tableViews objectAtIndex:tableIndex];
    newTableView.frame = CGRectMake(oldTableView.frame.origin.x + viewWidth, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
    
    if (simplePasscodeOn) {
        for (int i = 0; i < 4; i++) {
            [[[squares objectAtIndex:tableIndex] objectAtIndex:i] setImage:[UIImage imageNamed:@"passcode_square_empty.png"]];
        }    
    }
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.25];                    
    oldTableView.frame = CGRectMake(oldTableView.frame.origin.x - viewWidth, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
    newTableView.frame = self.view.frame;
    [UIView commitAnimations];
    
    if (tableIndex == [tableViews count] - 1) {
        [self addDoneButton];
    } else {
        [self addNextButton];
    }
    
    [[textFields objectAtIndex:tableIndex - 1] resignFirstResponder];
    [[textFields objectAtIndex:tableIndex] becomeFirstResponder];
}

- (void)moveToPreviousTableView {
    tableIndex -= 1;
    UITableView *oldTableView = [tableViews objectAtIndex:tableIndex + 1];
    UITableView *newTableView = [tableViews objectAtIndex:tableIndex];
    newTableView.frame = CGRectMake(oldTableView.frame.origin.x - viewWidth, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
    
    if (simplePasscodeOn) {
        for (int i = 0; i < 4; i++) {
            [[[squares objectAtIndex:tableIndex] objectAtIndex:i] setImage:[UIImage imageNamed:@"passcode_square_empty.png"]];
        }    
    }
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.25];                    
    oldTableView.frame = CGRectMake(oldTableView.frame.origin.x + viewWidth, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
    newTableView.frame = self.view.frame;
    [UIView commitAnimations];
    
    if (tableIndex == [tableViews count] - 1) {
        [self addDoneButton];
    } else {
        [self addNextButton];
    }
    
    [[textFields objectAtIndex:tableIndex + 1] resignFirstResponder];
    [[textFields objectAtIndex:tableIndex] becomeFirstResponder];
}

- (void)nextButtonPressed:(id)sender {
    
    UITextField *textField = [textFields objectAtIndex:tableIndex];
    
    if (![textField.text isEqualToString:@""]) {
        
        if (mode == kModeSetPasscode) {
            if ([textField isEqual:setPasscodeTextField]) {
                [self moveToNextTableView];
            } else if ([textField isEqual:confirmPasscodeTextField]) {
                if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                    confirmPasscodeTextField.text = @"";
                    setPasscodeTextField.text = @"";
                    passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                    [self moveToPreviousTableView];
                } else {
                    if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                        [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                    }
                    [self.passcodeLockViewController.tableView reloadData];
                    [self.settingsViewController.tableView reloadData];
                    [self dismissModalViewControllerAnimated:YES];
                }
            }            
        } else if (mode == kModeChangePasscode) {
            NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
            if ([textField isEqual:enterPasscodeTextField]) {
                if ([passcode isEqualToString:enterPasscodeTextField.text]) {
                    [self moveToNextTableView];
                } else {
                    [self incrementAndShowFailedAttemptsLabel];
                }
            } else if ([textField isEqual:setPasscodeTextField]) {
                if ([passcode isEqualToString:setPasscodeTextField.text]) {
                    setPasscodeTextField.text = @"";
                    passcodeConfirmationWarningLabel.text = @"Enter a different passcode. Cannot re-use the same passcode.";
                    passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 131.5, viewWidth, 60.0);
                } else {
                    passcodeConfirmationWarningLabel.text = @"";
                    passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 146.5, viewWidth, 30.0);
                    [self moveToNextTableView];
                }
            } else if ([textField isEqual:confirmPasscodeTextField]) {
                if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                    confirmPasscodeTextField.text = @"";
                    setPasscodeTextField.text = @"";
                    passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                    [self moveToPreviousTableView];
                } else {
                    if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                        [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                    }
                    [self.passcodeLockViewController.tableView reloadData];
                    [self.settingsViewController.tableView reloadData];
                    [self dismissModalViewControllerAnimated:YES];
                }
            }
        }
    }    
}

- (void)doneButtonPressed:(id)sender {
    
    UITextField *textField = [textFields objectAtIndex:tableIndex];
        
    if (mode == kModeEnterPasscode) {
        NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
        if ([enterPasscodeTextField.text isEqualToString:passcode]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [UIView beginAnimations:@"fadeIn" context:nil];
                [UIView setAnimationDelay:0.25];
                [UIView setAnimationDuration:0.5];
                OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
                for (UIViewController *svc in app.splitViewController.viewControllers) {
                    svc.view.alpha = 1.0;
                }
                [UIView commitAnimations];
            }
            [self dismissModalViewControllerAnimated:YES];
        } else { 
            [self incrementAndShowFailedAttemptsLabel];
        }
    } else if (mode == kModeSetPasscode) {
        if ([textField isEqual:setPasscodeTextField]) {
            [self moveToNextTableView];
        } else if ([textField isEqual:confirmPasscodeTextField]) {
            if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                confirmPasscodeTextField.text = @"";
                setPasscodeTextField.text = @"";
                passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                [self moveToPreviousTableView];
            } else {
                if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                    [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                }
                [self.passcodeLockViewController.tableView reloadData];
                [self.settingsViewController.tableView reloadData];
                [self dismissModalViewControllerAnimated:YES];
            }
        }            
    } else if (mode == kModeChangePasscode) {
        NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
        if ([textField isEqual:enterPasscodeTextField]) {
            if ([passcode isEqualToString:enterPasscodeTextField.text]) {
                [self moveToNextTableView];
            } else {
                [self incrementAndShowFailedAttemptsLabel];
            }
        } else if ([textField isEqual:setPasscodeTextField]) {
            if ([passcode isEqualToString:setPasscodeTextField.text]) {
                setPasscodeTextField.text = @"";
                passcodeConfirmationWarningLabel.text = @"Enter a different passcode. Cannot re-use the same passcode.";
                passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 131.5, viewWidth, 60.0);
            } else {
                passcodeConfirmationWarningLabel.text = @"";
                passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 146.5, viewWidth, 30.0);
                [self moveToNextTableView];
            }
        } else if ([textField isEqual:confirmPasscodeTextField]) {
            if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                confirmPasscodeTextField.text = @"";
                setPasscodeTextField.text = @"";
                passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                [self moveToPreviousTableView];
            } else {
                if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                    [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                }
                [self.passcodeLockViewController.tableView reloadData];
                [self.settingsViewController.tableView reloadData];
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    } else if (mode == kModeDisablePasscode) {
        NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
        if ([enterPasscodeTextField.text isEqualToString:passcode]) {
            if ([Keychain setString:@"NO" forKey:@"passcode_lock_passcode_on"]) {
                [Keychain setString:@"" forKey:@"passcode_lock_passcode"];
            }
            [self.passcodeLockViewController.tableView reloadData];
            [self.settingsViewController.tableView reloadData];
            [self dismissModalViewControllerAnimated:YES];
        } else { 
            [self incrementAndShowFailedAttemptsLabel];
        }
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];        
    simplePasscodeOn = [[Keychain getStringForKey:@"passcode_lock_simple_passcode_on"] isEqualToString:@"YES"];
    passcodeLockOn = [[Keychain getStringForKey:@"passcode_lock_passcode_on"] isEqualToString:@"YES"];
    eraseData = [[Keychain getStringForKey:@"passcode_lock_erase_data_on"] isEqualToString:@"YES"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        viewWidth = 540.0;
    } else {
        viewWidth = 320.0;
    }
}

- (UIView *)passwordHeaderViewForTextField:(UITextField *)textField {
    
    if (simplePasscodeOn) {
        textField.keyboardType = UIKeyboardTypeNumberPad;

        // hide the text field and add it to the view.  we'll use the squares, but we need a text field
        textField.hidden = YES;
        [self.view addSubview:textField];
    } else {
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyNext;
    }
    
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, 70.0)] autorelease];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 27.5, viewWidth, 30.0)];
    headerLabel.textColor = [UIColor tableViewHeaderColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:17.0];
    headerLabel.shadowOffset = CGSizeMake(0, 1.0);
    headerLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    if ([textField isEqual:setPasscodeTextField]) {
        passcodeConfirmationWarningLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 146.5, viewWidth, 30.0)];
        passcodeConfirmationWarningLabel.textColor = [UIColor tableViewHeaderColor];
        passcodeConfirmationWarningLabel.backgroundColor = [UIColor clearColor];
        passcodeConfirmationWarningLabel.textAlignment = UITextAlignmentCenter;
        passcodeConfirmationWarningLabel.font = [UIFont systemFontOfSize:14.0];
        passcodeConfirmationWarningLabel.shadowOffset = CGSizeMake(0, 1.0);
        passcodeConfirmationWarningLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        passcodeConfirmationWarningLabel.text = @"";
        passcodeConfirmationWarningLabel.numberOfLines = 0;
        passcodeConfirmationWarningLabel.lineBreakMode = UILineBreakModeWordWrap;
        [headerView addSubview:passcodeConfirmationWarningLabel];
    }
    
    if ([textField isEqual:enterPasscodeTextField]) {
        //UIView *failedAttemptsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 146.5, viewWidth, 30.0)];
        
        NSString *text = @"1 Failed Passcode Attempt";
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0]];
        failedAttemptsView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - (size.width + 36.0)) / 2, 147.5, size.width + 36.0, size.height + 10.0)];
        failedAttemptsLabel = [[UILabel alloc] initWithFrame:CGRectMake((viewWidth - (size.width + 36.0)) / 2, 147.5, size.width + 36.0, size.height + 10.0)]; 
        failedAttemptsLabel.backgroundColor = [UIColor clearColor];
        failedAttemptsLabel.textColor = [UIColor whiteColor];
        failedAttemptsLabel.text = text;
        failedAttemptsLabel.font = [UIFont boldSystemFontOfSize:14.0];
        failedAttemptsLabel.textAlignment = UITextAlignmentCenter;
        failedAttemptsLabel.shadowOffset = CGSizeMake(0, -1.0);
        failedAttemptsLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        failedAttemptsView.layer.cornerRadius = 14;
        failedAttemptsView.layer.borderWidth = 1.0;
        failedAttemptsView.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] CGColor];

        failedAttemptsLabel.hidden = YES;
        failedAttemptsView.hidden = YES;

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = failedAttemptsView.bounds;        
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.714 green:0.043 blue:0.043 alpha:1.0] CGColor], 
                                (id)[[UIColor colorWithRed:0.761 green:0.192 blue:0.192 alpha:1.0] CGColor], nil];
        [failedAttemptsView.layer insertSublayer:gradient atIndex:1];
        failedAttemptsView.layer.masksToBounds = YES;
        
        [headerView addSubview:failedAttemptsView];
        [headerView addSubview:failedAttemptsLabel];

        [failedAttemptsView release];
        [failedAttemptsLabel release];
    }
    
    if (mode == kModeSetPasscode) {
        self.navigationItem.title = @"Set Passcode";
        [self addCancelButton];    
        
        if ([textField isEqual:enterPasscodeTextField]) {
            headerLabel.text = @"Enter your passcode";
        } else if ([textField isEqual:setPasscodeTextField]) {
            headerLabel.text = @"Enter a passcode";
            [self addCancelButton];    
        } else if ([textField isEqual:confirmPasscodeTextField]) {
            headerLabel.text = @"Re-enter your passcode";
        }
    } else if (mode == kModeDisablePasscode) {
        self.navigationItem.title = @"Turn off Passcode";
        [self addCancelButton];    
        headerLabel.text = @"Enter your passcode";
    } else if (mode == kModeChangePasscode) {
        self.navigationItem.title = @"Change Passcode";
        [self addCancelButton];
        if ([textField isEqual:enterPasscodeTextField]) {
            headerLabel.text = @"Enter your old passcode";
        } else if ([textField isEqual:setPasscodeTextField]) {
            headerLabel.text = @"Enter your new passcode";
        } else {
            headerLabel.text = @"Re-enter your new passcode";
        }
    } else {
        self.navigationItem.title = @"Enter Passcode";
        headerLabel.text = @"Enter your passcode";
    }
    
    [headerView addSubview:headerLabel];
    [headerLabel release];
    
    return headerView;
}

- (NSArray *)squares {
    NSMutableArray *squareViews = [[NSMutableArray alloc] initWithCapacity:4];    
    NSInteger squareX = 23.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        squareX = 133.0;
    }
    
    for (int i = 0; i < 4; i++) {
        UIImageView *square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"passcode_square_empty.png"]];
        square.frame = CGRectMake(squareX, 74.0, 61.0, 53.0);
        [squareViews addObject:square];
        [square release];
        squareX += 71.0;
    }    
    return [[NSArray alloc] initWithArray:squareViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    enterPasscodeTextField = [self allocAndInitPasscodeTextField];
    setPasscodeTextField = [self allocAndInitPasscodeTextField];
    confirmPasscodeTextField = [self allocAndInitPasscodeTextField];

    tableViews = [[NSMutableArray alloc] init];
    textFields = [[NSMutableArray alloc] init];
    squares = [[NSMutableArray alloc] init];

    if (mode == kModeSetPasscode || mode == kModeChangePasscode) {
        // we're setting the passcode, so add possibly all of the table views
        if (passcodeLockOn) {
            enterPasscodeTableView.tableHeaderView = [self passwordHeaderViewForTextField:enterPasscodeTextField];
            [tableViews addObject:enterPasscodeTableView];
            [textFields addObject:enterPasscodeTextField];
            if (simplePasscodeOn) {
                [squares addObject:[self squares]];
                for (int i = 0; i < [[squares lastObject] count]; i++) {
                    [enterPasscodeTableView.tableHeaderView addSubview:[[squares lastObject] objectAtIndex:i]];
                }
            }
        }
        setPasscodeTableView.tableHeaderView = [self passwordHeaderViewForTextField:setPasscodeTextField];
        [tableViews addObject:setPasscodeTableView];
        [textFields addObject:setPasscodeTextField];
        if (simplePasscodeOn) {
            [squares addObject:[self squares]];
            for (int i = 0; i < [[squares lastObject] count]; i++) {
                [setPasscodeTableView.tableHeaderView addSubview:[[squares lastObject] objectAtIndex:i]];
            }
        }
        confirmPasscodeTableView.tableHeaderView = [self passwordHeaderViewForTextField:confirmPasscodeTextField];
        [tableViews addObject:confirmPasscodeTableView];
        [textFields addObject:confirmPasscodeTextField];
        if (simplePasscodeOn) {
            [squares addObject:[self squares]];
            for (int i = 0; i < [[squares lastObject] count]; i++) {
                [confirmPasscodeTableView.tableHeaderView addSubview:[[squares lastObject] objectAtIndex:i]];
            }
        }
    } else {        
        enterPasscodeTableView.tableHeaderView = [self passwordHeaderViewForTextField:enterPasscodeTextField];
        [tableViews addObject:enterPasscodeTableView];
        [textFields addObject:enterPasscodeTextField];
        if (simplePasscodeOn) {
            [squares addObject:[self squares]];
            for (int i = 0; i < [[squares lastObject] count]; i++) {
                [enterPasscodeTableView.tableHeaderView addSubview:[[squares lastObject] objectAtIndex:i]];
            }
        }
    }
    
    [self.view addSubview:[tableViews objectAtIndex:0]];

    // shift any extra table views away
    for (int i = 1; i < [tableViews count]; i++) {
        UITableView *tableView = [tableViews objectAtIndex:i];
        tableView.frame = CGRectMake(tableView.frame.origin.x + viewWidth, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height);
        [self.view addSubview:tableView];
    }
    
    if (tableIndex == [tableViews count] - 1) {
        [self addDoneButton];
    } else {
        [self addNextButton];
    }
    
    [[textFields objectAtIndex:0] becomeFirstResponder];
    [[tableViews objectAtIndex:0] reloadData];
    [[textFields objectAtIndex:[tableViews count] - 1] setReturnKeyType:UIReturnKeyDone];

    // table looks all screwy on iPad at first, so shuffle around to get the drawing right
    // yes, i know this is a dirty hack.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([tableViews count] > 1) {
            [self moveToNextTableView];
            [self moveToPreviousTableView];
        } else {
            UITableView *tv = [tableViews objectAtIndex:0];
            tv.frame = CGRectMake(tv.frame.origin.x, tv.frame.origin.y, 768.0, 960.0);
        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return simplePasscodeOn ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    //cell.accessoryView = enterPasscodeTextField; //[textFields objectAtIndex:tableIndex];
    if ([aTableView isEqual:enterPasscodeTableView]) {
        cell.accessoryView = enterPasscodeTextField;
    } else if ([aTableView isEqual:setPasscodeTableView]) {
        cell.accessoryView = setPasscodeTextField;
    } else if ([aTableView isEqual:confirmPasscodeTableView]) {
        cell.accessoryView = confirmPasscodeTextField;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Text Field Delegate

/*
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    // we don't want iPad users to be able to dismiss the keyboard at all
    return NO;
}
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:[textFields lastObject]]) {
        [self doneButtonPressed:nil];
    } else {
        [self nextButtonPressed:nil];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // if we're in simple passcode mode, update the squares to show entered numbers
    if (simplePasscodeOn) {
        NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];

        // we're setting here and returning no since i'm messing with the responder chain.
        // otherwise the last character will become the first character of the next textField
        textField.text = result;
        
        for (int i = 0; i < 4; i++) {
            UIImageView *square = [[squares objectAtIndex:tableIndex] objectAtIndex:i];
            if (i < [result length]) {
                square.image = [UIImage imageNamed:@"passcode_square_filled.png"];
            } else {
                square.image = [UIImage imageNamed:@"passcode_square_empty.png"];
            }
        }
        
        // if we're at 4 characters, it could be time to move on to confirming
        if ([result length] == 4) {

            if (mode == kModeDisablePasscode) {
                NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
                if ([enterPasscodeTextField.text isEqualToString:passcode]) {
                    if ([Keychain setString:@"NO" forKey:@"passcode_lock_passcode_on"]) {
                        [Keychain setString:@"" forKey:@"passcode_lock_passcode"];
                    }
                    [self.passcodeLockViewController.tableView reloadData];
                    [self.settingsViewController.tableView reloadData];
                    [self dismissModalViewControllerAnimated:YES];
                } else { 
                    [self incrementAndShowFailedAttemptsLabel];
                }
            } else if (mode == kModeEnterPasscode) {
                NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
                if ([enterPasscodeTextField.text isEqualToString:passcode]) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        [UIView beginAnimations:@"fadeIn" context:nil];
                        [UIView setAnimationDelay:0.25];
                        [UIView setAnimationDuration:0.5];
                        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
                        for (UIViewController *svc in app.splitViewController.viewControllers) {
                            svc.view.alpha = 1.0;
                        }
                        [UIView commitAnimations];
                    }
                    [self dismissModalViewControllerAnimated:YES];
                } else { 
                    [self incrementAndShowFailedAttemptsLabel];
                }
            } else if (mode == kModeChangePasscode) {
                NSString *passcode = [Keychain getStringForKey:@"passcode_lock_passcode"];
                if ([textField isEqual:enterPasscodeTextField]) {
                    if ([passcode isEqualToString:enterPasscodeTextField.text]) {
                        [self moveToNextTableView];
                    } else {
                        [self incrementAndShowFailedAttemptsLabel];
                    }
                } else if ([textField isEqual:setPasscodeTextField]) {
                    if ([passcode isEqualToString:setPasscodeTextField.text]) {
                        setPasscodeTextField.text = @"";
                        for (int i = 0; i < 4; i++) {
                            [[[squares objectAtIndex:tableIndex] objectAtIndex:i] setImage:[UIImage imageNamed:@"passcode_square_empty.png"]];
                        }    
                        passcodeConfirmationWarningLabel.text = @"Enter a different passcode. Cannot re-use the same passcode.";
                        passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 131.5, viewWidth, 60.0);
                    } else {
                        passcodeConfirmationWarningLabel.text = @"";
                        passcodeConfirmationWarningLabel.frame = CGRectMake(0.0, 146.5, viewWidth, 30.0);
                        [self moveToNextTableView];
                    }
                } else if ([textField isEqual:confirmPasscodeTextField]) {
                    if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                        confirmPasscodeTextField.text = @"";
                        setPasscodeTextField.text = @"";
                        passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                        [self moveToPreviousTableView];
                    } else {
                        if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                            [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                        }
                        [self.passcodeLockViewController.tableView reloadData];
                        [self.settingsViewController.tableView reloadData];
                        [self dismissModalViewControllerAnimated:YES];
                    }
                }
            } else if ([textField isEqual:setPasscodeTextField]) {
                [self moveToNextTableView];
            } else if ([textField isEqual:confirmPasscodeTextField]) {
                if (![confirmPasscodeTextField.text isEqualToString:setPasscodeTextField.text]) {
                    confirmPasscodeTextField.text = @"";
                    setPasscodeTextField.text = @"";
                    passcodeConfirmationWarningLabel.text = @"Passcodes did not match. Try again.";
                    [self moveToPreviousTableView];
                } else {
                    if ([Keychain setString:setPasscodeTextField.text forKey:@"passcode_lock_passcode"]) {
                        [Keychain setString:@"YES" forKey:@"passcode_lock_passcode_on"];
                    }
                    [self.passcodeLockViewController.tableView reloadData];
                    [self.settingsViewController.tableView reloadData];
                    [self dismissModalViewControllerAnimated:YES];
                }
            }
        }
        
        return NO;
    }

    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [enterPasscodeTextField release];
    [setPasscodeTextField release];
    [confirmPasscodeTextField release];
    [tableViews release];
    [textFields release];
    [squares release];
    [passcodeLockViewController release];
    [settingsViewController release];
    [rootViewController release];
    [accountHomeViewController release];
    [super dealloc];
}

@end
