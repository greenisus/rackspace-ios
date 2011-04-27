//
//  AccountDetailsViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AccountDetailsViewController.h"
#import "Provider.h"
#import "RSTextFieldCell.h"
#import "OpenStackAccount.h"
#import "RootViewController.h"
#import "ProvidersViewController.h"
#import "OpenStackRequest.h"
#import "UIViewController+Conveniences.h"
#import "NSString+Conveniences.h"
#import "ActivityIndicatorView.h"
#import "APILogger.h"


#define kUsername 0
#define kAPIKey 1

#define kProviderName 0
#define kAuthEndpoint 1

@implementation AccountDetailsViewController

@synthesize provider, rootViewController, providersViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark HTTP Response Handlers

- (void)authenticationSucceded:(OpenStackRequest *)request {
    
    [activityIndicatorView removeFromSuperviewAndRelease];
    
    if ([request responseStatusCode] == 204) {        
        account.authToken = [[request responseHeaders] objectForKey:@"X-Auth-Token"];
        account.serversURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Server-Management-Url"]];
        account.filesURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Storage-Url"]];
        account.cdnURL = [NSURL URLWithString:[[request responseHeaders] objectForKey:@"X-Cdn-Management-Url"]];
        [account persist];
        [account release];
        [rootViewController.tableView reloadData];
        [account refreshCollections];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self alert:@"Authentication Failure" message:@"Please check your User Name and API Key."];
    }
}

- (void)authenticationFailed:(OpenStackRequest *)request {
    [activityIndicatorView removeFromSuperviewAndRelease];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if ([request responseStatusCode] == 401) {
        [self alert:@"Authentication Failure" message:@"Please check your User Name and API Key."];
    } else {
        [self failOnBadConnection];
    }
}

- (void)authenticate {
    
    BOOL valid = YES;
    
    if (customProvider) {
        valid = valid && providerNameTextField.text && ![@"" isEqualToString:providerNameTextField.text];
        if (!valid) {
            [self alert:nil message:@"Please enter a provider name."];
            [providerNameTextField becomeFirstResponder];
        } else {
            valid = valid && apiEndpointTextField.text && ![@"" isEqualToString:apiEndpointTextField.text];
            if (!valid) {
                [self alert:nil message:@"Please enter an API authentication URL."];
                [apiEndpointTextField becomeFirstResponder];
            } else {
                valid = valid && apiEndpointTextField.text && [apiEndpointTextField.text isURL];
                if (!valid) {
                    [self alert:nil message:@"Please enter a valid API authentication URL."];
                    [apiEndpointTextField becomeFirstResponder];
                } else {
                    valid = valid && usernameTextField.text && ![@"" isEqualToString:usernameTextField.text];
                    if (!valid) {
                        [self alert:nil message:@"Please enter your username."];
                        [usernameTextField becomeFirstResponder];
                    } else {
                        valid = valid && apiKeyTextField.text && ![@"" isEqualToString:apiKeyTextField.text];
                        if (!valid) {
                            [self alert:nil message:@"Please enter your API key."];
                            [apiKeyTextField becomeFirstResponder];
                        } else {
                            account = [[OpenStackAccount alloc] init];
                            account.provider = provider;
                            
                            if (!account.provider) {
                                Provider *p = [[Provider alloc] init];
                                p.name = providerNameTextField.text;                                
                                
                                NSString *urlString = apiEndpointTextField.text;
                                if ([urlString characterAtIndex:[urlString length] - 1] == '/') {
                                    urlString = [urlString substringToIndex:[urlString length] - 1];
                                }
                                
                                p.authEndpointURL = [NSURL URLWithString:urlString];
                                account.provider = p;
                                [p release];
                            }
                            
                            account.username = usernameTextField.text;
                            account.apiKey = [NSString stringWithString:apiKeyTextField.text];
                            
                            activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Authenticating..."] text:@"Authenticating..."];
                            [activityIndicatorView addToView:self.view];
                            
                            OpenStackRequest *request = [OpenStackRequest authenticationRequest:account];
                            request.delegate = self;
                            request.didFinishSelector = @selector(authenticationSucceded:);
                            request.didFailSelector = @selector(authenticationFailed:);
                            [request startAsynchronous];
                        }
                    }
                }                
            }
        }
    } else {
        valid = valid && usernameTextField.text && ![@"" isEqualToString:usernameTextField.text];
        if (!valid) {
            [self alert:nil message:@"Please enter your username."];
            [usernameTextField becomeFirstResponder];
        } else {
            valid = valid && apiKeyTextField.text && ![@"" isEqualToString:apiKeyTextField.text];
            if (!valid) {
                [self alert:nil message:@"Please enter your API key."];
                [apiKeyTextField becomeFirstResponder];
            } else {
                account = [[OpenStackAccount alloc] init];
                account.provider = provider;
                account.username = usernameTextField.text;
                account.apiKey = apiKeyTextField.text;                        
                
                activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Authenticating..."] text:@"Authenticating..."];
                [activityIndicatorView addToView:self.view];
                
                OpenStackRequest *request = [OpenStackRequest authenticationRequest:account];
                request.delegate = self;
                request.didFinishSelector = @selector(authenticationSucceded:);
                request.didFailSelector = @selector(authenticationFailed:);
                [request startAsynchronous];
            }
        }
    }
}

#pragma mark -
#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    tableShrunk = NO;
    CGRect rect = self.tableView.frame;
    rect.size.height = 416.0;
    self.tableView.frame = rect;
    [self authenticate];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Authentication";
    providerSection = -1;
    authenticationSection = 0;
    [self addSaveButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (provider == nil) {
        customProvider = YES;
        providerSection = 0;
        authenticationSection = 1;
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [customProvider ? providerNameTextField : usernameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [usernameTextField resignFirstResponder];
    [apiKeyTextField resignFirstResponder];
    [providerNameTextField resignFirstResponder];
    [apiEndpointTextField resignFirstResponder];
    tableShrunk = NO;
    CGRect rect = self.tableView.frame;
    rect.size.height = 416.0;
    self.tableView.frame = rect;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return customProvider ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == authenticationSection) {
        if (customProvider) {
            return @"Login";
        } else {
            return [NSString stringWithFormat:@"%@ Login", provider.name];
        }
    } else if (section == providerSection) {
        return @"Provider Details";
    } else {
        return @"";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (customProvider) {
        return @"";
    } else {
        return provider.authHelpMessage;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    RSTextFieldCell *cell = (RSTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RSTextFieldCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    if (indexPath.section == authenticationSection) {
        if (indexPath.row == kUsername) {
            cell.textLabel.text = @"Username";
            usernameTextField = cell.textField;
            usernameTextField.secureTextEntry = NO;
            usernameTextField.delegate = self;
            usernameTextField.returnKeyType = UIReturnKeyNext;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGRect rect = usernameTextField.frame;
                CGFloat offset = 19.0;
                usernameTextField.frame = CGRectMake(rect.origin.x + offset, rect.origin.y, rect.size.width - offset, rect.size.height);
            }
        } else if (indexPath.row == kAPIKey) {
            cell.textLabel.text = @"API Key";
            apiKeyTextField = cell.textField;
            apiKeyTextField.secureTextEntry = YES;
            apiKeyTextField.delegate = self;
            apiKeyTextField.returnKeyType = UIReturnKeyDone;
        }
    } else if (indexPath.section == providerSection) {
        if (indexPath.row == kProviderName) {
            cell.textLabel.text = @"Name";
            providerNameTextField = cell.textField;
            providerNameTextField.secureTextEntry = NO;
            providerNameTextField.delegate = self;
            providerNameTextField.returnKeyType = UIReturnKeyNext;
            providerNameTextField.placeholder = @"Ex: Rackspace Cloud";
        } else if (indexPath.row == kAuthEndpoint) {
            cell.textLabel.text = @"API URL";
            apiEndpointTextField = cell.textField;
            apiEndpointTextField.secureTextEntry = NO;
            apiEndpointTextField.delegate = self;
            apiEndpointTextField.returnKeyType = UIReturnKeyNext;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)tableShrinkAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    UITextField *textField = ((UITextField *)context);
    if ([textField isEqual:apiKeyTextField] || [textField isEqual:usernameTextField]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {    
    if (!tableShrunk) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [UIView beginAnimations:nil context:textField];
            [UIView setAnimationDuration:0.35];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(tableShrinkAnimationDidStop:finished:context:)];
            CGRect rect = self.tableView.frame;
            rect.size.height = 200.0;
            self.tableView.frame = rect;
            [UIView commitAnimations];
            tableShrunk = YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [textField resignFirstResponder];

    if ([textField isEqual:providerNameTextField]) {
        [apiEndpointTextField becomeFirstResponder];
    } else if ([textField isEqual:apiEndpointTextField]) {
        [usernameTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else if ([textField isEqual:usernameTextField]) {
        [apiKeyTextField becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kAPIKey inSection:authenticationSection] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;        
        tableShrunk = NO;
        CGRect rect = self.tableView.frame;
        rect.size.height = 416.0;
        self.tableView.frame = rect;
        [self authenticate];
    }
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [provider release];
    [rootViewController release];
    [providersViewController release];
    [super dealloc];
}

@end
