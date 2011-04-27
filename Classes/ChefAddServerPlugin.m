//
//  ChefAddServerPlugin.m
//  OpenStack
//
//  Created by Mike Mayo on 10/31/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ChefAddServerPlugin.h"
#import "AddServerPluginHandler.h"
#import "UIColor+MoreColors.h"
#import "Server.h"
#import "Keychain.h"

@implementation ChefAddServerPlugin

@synthesize chefBootstrappingSwitch;

+ (void)load {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    ChefAddServerPlugin *plugin = [[ChefAddServerPlugin alloc] init];
    
    [AddServerPluginHandler registerPlugin:plugin];
    
    [plugin release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults stringForKey:@"chef_bootstrapping_on"]) {
        [defaults setValue:@"NO" forKey:@"chef_bootstrapping_on"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_default_on"]) {
        [defaults setValue:@"NO" forKey:@"chef_bootstrapping_default_on"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_endpoint_type"]) {
        [defaults setValue:@"opscode" forKey:@"chef_bootstrapping_endpoint_type"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_opscode_organization"]) {
        [defaults setValue:@"" forKey:@"chef_bootstrapping_opscode_organization"];
    }
    if (![defaults stringForKey:@"chef_bootstrapping_chef_server_url"]) {
        [defaults setValue:@"" forKey:@"chef_bootstrapping_chef_server_url"];
    }
    if (![Keychain getStringForKey:@"chef_bootstrapping_validator_key"]) {
        [Keychain setString:@"" forKey:@"chef_bootstrapping_validator_key"];
    }
    [defaults synchronize];
    
    [pool release];
}

- (BOOL)isConfigurationValid {
    BOOL isConfigurationValid = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // validate an endpoint type has been chosen
    isConfigurationValid = isConfigurationValid && ![[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@""];
    
    // validate endpoint configuration
    if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"opscode"]) {
        isConfigurationValid = isConfigurationValid && ![[defaults stringForKey:@"chef_bootstrapping_opscode_organization"] isEqualToString:@""];
    } else if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"chef_server"]) {
        isConfigurationValid = isConfigurationValid && ![[defaults stringForKey:@"chef_bootstrapping_chef_server_url"] isEqualToString:@""];
    }
    
    // validate presence of validator key
    isConfigurationValid = isConfigurationValid && ![[Keychain getStringForKey:@"chef_bootstrapping_validator_key"] isEqualToString:@""];
    
    return isConfigurationValid;
}

- (void)pluginWillAppear {
    chefBootstrappingSwitch = [[UISwitch alloc] init];
    [chefBootstrappingSwitch addTarget:self action:@selector(chefBootstrappingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (![self isConfigurationValid]) {
        chefBootstrappingSwitch.enabled = NO;
    }    
}

- (BOOL)pluginShouldAppear {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults stringForKey:@"chef_bootstrapping_on"] isEqualToString:@"YES"];
}

- (void)chefBootstrappingSwitchChanged:(id)sender {
    
    // save the default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (chefBootstrappingSwitch.on) {
        [defaults setValue:@"YES" forKey:@"chef_bootstrapping_default_on"];
    } else {
        [defaults setValue:@"NO" forKey:@"chef_bootstrapping_default_on"];
    }
    [defaults synchronize];
    
    // update the tableView
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 1; i < 2; i++) {
        // TODO: the plugin shouldn't need to know its table section
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:2]];
    }
    
    if (chefBootstrappingSwitch.on) {
        [addServerTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [addServerTableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } else {
        [addServerTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self isConfigurationValid]) {
        return @"Chef will output to /var/log/chef.out and /var/log/chef.err on your Cloud Server.";
    } else {
        return @"Chef bootstrapping is disabled because your configuration is incomplete.";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (chefBootstrappingSwitch && [self isConfigurationValid]) {
        return chefBootstrappingSwitch.on ? 2 : 1;
    } else {
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChefSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        addServerTableView = tableView;
        runListTextField = [[UITextField alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        runListTextField = [[UITextField alloc] initWithFrame:CGRectMake(77.0, 13.0, 198.0, 24.0)];
        runListTextField.delegate = self;
        runListTextField.font = [UIFont systemFontOfSize:17.0];
        runListTextField.textColor = [UIColor value1DetailTextLabelColor];
        runListTextField.backgroundColor = [UIColor clearColor];
        runListTextField.textAlignment = UITextAlignmentRight;
        runListTextField.returnKeyType = UIReturnKeyDone;
        runListTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        runListTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        runListTextField.placeholder = @"Ex: role[db] recipe[a]";
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Chef Bootstrapping";
        cell.accessoryView = chefBootstrappingSwitch;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        chefBootstrappingSwitch.on = [self isConfigurationValid] && [[defaults stringForKey:@"chef_bootstrapping_default_on"] isEqualToString:@"YES"];
        
        if (![self isConfigurationValid]) {
            cell.textLabel.enabled = NO;
        }
    } else {
        cell.textLabel.text = @"Run List";
        cell.accessoryView = runListTextField;
    }
    
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

#pragma mark -
#pragma mark Chef File Prep

- (void)addRunlistToPersonality:(NSDictionary **)personality {
    
    NSString *content = @"{ \"run_list\": ["; 
    
    NSArray *items = [runListTextField.text componentsSeparatedByString:@" "];
    for (int i = 0; i < [items count]; i++) {
        content = [NSString stringWithFormat:@"%@ \"%@\"", content, [items objectAtIndex:i]];
        if (i < ([items count] - 1)) {
            content = [NSString stringWithFormat:@"%@, ", content];
        }
    }
    
    content = [NSString stringWithFormat:@"%@ ] }", content];
    [*personality setValue:content forKey:@"/etc/chef/first-boot.json"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark -
#pragma mark Server Configuration

- (void)insertFile:(NSString *)filename path:(NSString *)path personality:(NSDictionary **)personality template:(NSDictionary *)template {
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    
    for (NSString *key in template) {
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<%@>", key] withString:[template objectForKey:key]];
    }

    NSLog(@"\n\n%@:", path);
    NSLog(@"%@\n\n", content);

    [*personality setValue:content forKey:path];
}

- (void)insertFile:(NSString *)filename path:(NSString *)path personality:(NSDictionary **)personality {
    [self insertFile:filename path:path personality:personality template:nil];
}

- (void)configureServer:(Server **)server {
    if (chefBootstrappingSwitch.on) {
        NSMutableDictionary *personality = [[NSMutableDictionary alloc] initWithCapacity:5];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *chefServerUrl;
        NSString *validationClientName;
        
        // add files and templates
        [self insertFile:@"chef_plugin_crontab" path:@"/var/spool/cron/crontabs/root" personality:&personality];
        [self insertFile:@"chef_plugin_install_script" path:@"/etc/install-chef" personality:&personality];
        
        if ([[defaults stringForKey:@"chef_bootstrapping_endpoint_type"] isEqualToString:@"opscode"]) {
            chefServerUrl = [NSString stringWithFormat:@"https://api.opscode.com/organizations/%@", [defaults stringForKey:@"chef_bootstrapping_opscode_organization"]];
            validationClientName = [NSString stringWithFormat:@"%@-validator", [defaults stringForKey:@"chef_bootstrapping_opscode_organization"]];
        } else {
            chefServerUrl = [defaults stringForKey:@"chef_bootstrapping_chef_server_url"];
            validationClientName = @"chef-validator";
        }
        
        [self insertFile:@"chef_plugin_client_template" path:@"/etc/chef/client.rb" personality:&personality 
                template:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:chefServerUrl, validationClientName, nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"chef_server_url", @"validation_client_name", nil]]];
        
        // add the validator key
        [personality setValue:[Keychain getStringForKey:@"chef_bootstrapping_validator_key"] forKey:@"/etc/chef/validation.pem"];
        
        // add the run list
        [self addRunlistToPersonality:&personality];
        
        [*server setPersonality:[NSDictionary dictionaryWithDictionary:personality]];    
        [personality release];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [chefBootstrappingSwitch release];
    [super dealloc];
}

@end
