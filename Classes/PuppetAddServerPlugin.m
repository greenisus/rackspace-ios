//
//  PuppetAddServerPlugin.m
//  OpenStack
//
//  Created by Michael Mayo on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PuppetAddServerPlugin.h"
#import "AddServerPluginHandler.h"
#import "UIColor+MoreColors.h"
#import "Server.h"


@implementation PuppetAddServerPlugin

@synthesize puppetBootstrappingSwitch;

+ (void)load {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    PuppetAddServerPlugin *plugin = [[PuppetAddServerPlugin alloc] init];
    
    [AddServerPluginHandler registerPlugin:plugin];
    
    [plugin release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults stringForKey:@"puppet_bootstrapping_on"]) {
        [defaults setValue:@"NO" forKey:@"puppet_bootstrapping_on"];
    }
    if (![defaults stringForKey:@"puppet_bootstrapping_default_on"]) {
        [defaults setValue:@"NO" forKey:@"puppet_bootstrapping_default_on"];
    }
    if (![defaults stringForKey:@"puppet_bootstrapping_server_url"]) {
        [defaults setValue:@"" forKey:@"puppet_bootstrapping_server_url"];
    }
    [defaults synchronize];
    
    [pool release];
}

- (BOOL)isConfigurationValid {
    BOOL isConfigurationValid = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    isConfigurationValid = isConfigurationValid && ![[defaults stringForKey:@"puppet_bootstrapping_server_url"] isEqualToString:@""];
    return isConfigurationValid;
}

- (void)pluginWillAppear {
    puppetBootstrappingSwitch = [[UISwitch alloc] init];
    [puppetBootstrappingSwitch addTarget:self action:@selector(puppetBootstrappingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (![self isConfigurationValid]) {
        puppetBootstrappingSwitch.enabled = NO;
    }    
}

- (BOOL)pluginShouldAppear {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults stringForKey:@"puppet_bootstrapping_on"] isEqualToString:@"YES"];
}

- (void)puppetBootstrappingSwitchChanged:(id)sender {
    
    // save the default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (puppetBootstrappingSwitch.on) {
        [defaults setValue:@"YES" forKey:@"puppet_bootstrapping_default_on"];
    } else {
        [defaults setValue:@"NO" forKey:@"puppet_bootstrapping_default_on"];
    }
    [defaults synchronize];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self isConfigurationValid]) {
        return @"Puppet will output to /var/log/puppet.out and /var/log/puppet.err on your Cloud Server.";
    } else {
        return @"Puppet bootstrapping is disabled because your configuration is incomplete.";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PuppetSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        addServerTableView = tableView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = @"Puppet";
    cell.accessoryView = puppetBootstrappingSwitch;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    puppetBootstrappingSwitch.on = [self isConfigurationValid] && [[defaults stringForKey:@"puppet_bootstrapping_default_on"] isEqualToString:@"YES"];
    
    if (![self isConfigurationValid]) {
        cell.textLabel.enabled = NO;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

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
    if (puppetBootstrappingSwitch.on) {
        NSMutableDictionary *personality = [[NSMutableDictionary alloc] initWithCapacity:5];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *puppetServerUrl;
        
        // add files and templates
        [self insertFile:@"puppet_plugin_crontab" path:@"/var/spool/cron/crontabs/root" personality:&personality];
        [self insertFile:@"puppet_plugin_install_script" path:@"/etc/install-puppet" personality:&personality];
        
        puppetServerUrl = [defaults stringForKey:@"puppet_bootstrapping_server_url"];
        
        [self insertFile:@"puppet_plugin_client_template" path:@"/etc/puppet/puppet.conf" personality:&personality 
                template:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:puppetServerUrl, nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"puppet_server", nil]]];
        
        [*server setPersonality:[NSDictionary dictionaryWithDictionary:personality]];    
        [personality release];
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [puppetBootstrappingSwitch release];
    [super dealloc];
}

@end
