//
//  ChefValidationKeyViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 11/4/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ChefValidationKeyViewController.h"
#import "UIColor+MoreColors.h"
#import "Keychain.h"
#import "UIViewController+Conveniences.h"

@implementation ChefValidationKeyViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Validator Key";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usingOpscodePlatform = [[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"opscode"];
    organization = [defaults stringForKey:@"chef_bootstrapping_opscode_organization"];
    
    // look for any files that end with .pem
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSMutableDictionary *pemFileContents = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [files count]; i++) {
        NSString *path = [files objectAtIndex:i];
        if ([[[path componentsSeparatedByString:@"."] lastObject] isEqualToString:@"pem"]) {
            [pemFileContents setObject:[NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", path]] encoding:NSUTF8StringEncoding error:nil] forKey:path];
        }
    }
    
    pemFiles = [[NSDictionary alloc] initWithDictionary:pemFileContents];
    
    sortedPemFilenames = [[NSArray alloc] initWithArray:[[pemFiles allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    [pemFileContents release];
    [fileManager release];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(26.0, 13.0, 226.0, 24.0)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        textField.frame = CGRectMake(26.0, 13.0, 416.0, 24.0);
    }
    textField.delegate = self;
    textField.placeholder = @"Paste validator key here";
    textField.secureTextEntry = YES;
    textField.font = [UIFont systemFontOfSize:17.0];
    textField.textColor = [UIColor value1DetailTextLabelColor];
    textField.backgroundColor = [UIColor clearColor];
    textField.textAlignment = UITextAlignmentRight;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.text = [Keychain getStringForKey:@"chef_bootstrapping_validator_key"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [pemFiles count] > 0 ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([pemFiles count] > 0) {
        if (section == 0) {
            return [pemFiles count];
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([pemFiles count] > 0) {
        if (section == 0) {
            return @"If you select a key synced from iTunes, it will be stored in your keychain.  You should then delete the file in iTunes to protect your key.";
        } else {
            return @"If you do not select a key file, you can enter it here.";
        }
    } else {
        if (usingOpscodePlatform) {
            return [NSString stringWithFormat:@"To communicate with the Opscode Platform, you must provide your validator key.  The validator key is inside the %@-validator.pem file you received when you signed up for the Opscode Platform.", organization];
        } else {
            return @"To communicate with your Chef server, you must provide your validator key.  The validator key is probably your validation.pem file.";
        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    if ([pemFiles count] > 0 && indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"/%@", [sortedPemFilenames objectAtIndex:indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        if ([indexPath isEqual:selectedIndexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        cell.textLabel.text = @"Key";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = textField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([pemFiles count] > 0 && indexPath.section == 0) {
        selectedIndexPath = indexPath;
        
        NSString *pemKey = [sortedPemFilenames objectAtIndex:indexPath.row];
        /*
        textField.text = [pemFiles objectForKey:pemKey];
        
        NSString *key = textField.text;
        
        // UITextField doesn't respect line breaks, so let's insert them here.
        // If the string isn't the right length, it's not valid anyway
        // so it doesn't matter if the change fails.  We're doing this instead of simply
        // using a UITextView because only UITextField supports the secureTextEntry property
        
        key = [key stringByReplacingOccurrencesOfString:@"-----BEGIN RSA PRIVATE KEY----- " withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"-----END RSA PRIVATE KEY----- " withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
        key = [NSString stringWithFormat:@"-----BEGIN RSA PRIVATE KEY-----\n%@\n-----END RSA PRIVATE KEY-----\n", key];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
        */
        [Keychain setString:[pemFiles objectForKey:pemKey] forKey:@"chef_bootstrapping_validator_key"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [aTextField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *key = [aTextField.text stringByReplacingCharactersInRange:range withString:string];
    
    // UITextField doesn't respect line breaks, so let's insert them here.
    // If the string isn't the right length, it's not valid anyway
    // so it doesn't matter if the change fails.  We're doing this instead of simply
    // using a UITextView because only UITextField supports the secureTextEntry property
    
    key = [key stringByReplacingOccurrencesOfString:@"-----BEGIN RSA PRIVATE KEY----- " withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"-----END RSA PRIVATE KEY----- " withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    key = [NSString stringWithFormat:@"-----BEGIN RSA PRIVATE KEY-----\n%@-----END RSA PRIVATE KEY-----\n", key];

    
    [Keychain setString:key forKey:@"chef_bootstrapping_validator_key"];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [pemFiles release];
    [sortedPemFilenames release];
    [super dealloc];
}


@end

