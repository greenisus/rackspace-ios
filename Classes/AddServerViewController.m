//
//  AddServerViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 10/8/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AddServerViewController.h"
#import "OpenStackAccount.h"
#import "Image.h"
#import "Flavor.h"
#import "Server.h"
#import "UIViewController+Conveniences.h"
#import "ImagePickerViewController.h"
#import "UIColor+MoreColors.h"
#import "SimpleImagePickerViewController.h"
#import "Provider.h"
#import "AddServerPlugin.h"
#import "AddServerPluginHandler.h"
#import "ServersViewController.h"
#import "AccountManager.h"
#import "OpenStackRequest.h"
#import "LogEntryModalViewController.h"
#import "APILogEntry.h"
#import "RateLimit.h"
#import "RSTextFieldCell.h"
#import "OpenStackAppDelegate.h"
#import "AccountHomeViewController.h"
#import "ServerViewController.h"
#import "AccountHomeViewController.h"

#define kNodeCount 0
#define kNodeDetails 1

#define kName 0
#define kSize 1
#define kImageRow 2

// TODO: bring back passwords

/*
 Files
 <file injection ui, however that should work; pick from files synced from iTunes i guess. maybe object storage>
 
 --- third party section ---
    -- third party server create tools should be a plugin style, separate classes --
 [Chef Bootstrapped - on/off]
    run list
    <sub text from iPad>  Visit opscode.com/chef for more information.
    (perhaps load roles and recipes via API)

 [Puppet Bootstrapped - on/off]
    whatever puppet "plugin" needs
 */
 
@implementation AddServerViewController

@synthesize account, selectedImage, serversViewController, accountHomeViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setNewSelectedImage:(Image *)image {
    self.selectedImage = image;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark -
#pragma mark Button Handlers

- (void)saveButtonPressed:(id)sender {
    
    // validate required fields?  name isn't actually required; flavor and image are defaulted
    
    // populate the server(s) info, then pass the server along to all the plugins
    for (int i = 0; i < nodeCount; i++) {
        Server *server = [[Server alloc] init];
        if (nodeCount == 1) {
            server.name = nameTextField.text;
        } else {            
            if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""]) {
                server.name = [NSString stringWithFormat:@"slice%i", i + 1];
            } else {
                server.name = [NSString stringWithFormat:@"%@%i", nameTextField.text, i + 1];
            }
        }
        server.flavor = [self.account.sortedFlavors objectAtIndex:flavorIndex];
        
        server.image = selectedImage;

        for (int i = 0; i < [plugins count]; i++) {
            id <AddServerPlugin> plugin = [plugins objectAtIndex:i];
            [plugin configureServer:&server];
        }
        
        // TODO: handle plugin validation and check personality file count
        //       perhaps via configureServer throwing an exception?

        [account.manager createServer:server];
        
        // now we need to register for the creation success and failure events.
        id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"createServerSucceeded" object:server 
                                                                        queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            successCount++;
            
            // insert the server into the account's sorted array
            NSMutableDictionary *servers = [[NSMutableDictionary alloc] initWithDictionary:self.account.servers];
            
            OpenStackRequest *request = [notification.userInfo objectForKey:@"request"];
            Server *createdServer = [request server];
            createdServer.flavor = [self.account.flavors objectForKey:[NSNumber numberWithInt:createdServer.flavorId]];
            createdServer.image = [self.account.images objectForKey:[NSNumber numberWithInt:createdServer.imageId]];
            
            [servers setObject:createdServer forKey:[NSNumber numberWithInt:createdServer.identifier]];
            
            self.account.servers = [NSMutableDictionary dictionaryWithDictionary:servers];
            
            [servers release];
            
            [self.account persist];
            
            // insert the server into the servers list table
            // using reloadData instead of insertRows to avoid race conditions
            serversViewController.tableView.allowsSelection = YES;
            serversViewController.tableView.scrollEnabled = YES;
            [serversViewController.tableView reloadData];
            
            if (nodeCount - successCount - failureCount == 0) {
                [serversViewController hideToolbarActivityMessage];
            } else {
                if (nodeCount - successCount - failureCount == 1) {
                    [serversViewController showToolbarActivityMessage:@"Creating 1 server..."];
                } else {
                    [serversViewController showToolbarActivityMessage:[NSString stringWithFormat:@"Creating %i servers...", nodeCount - successCount - failureCount]];
                }
            }
            
            if (failureCount + successCount == nodeCount) {
                [serversViewController hideToolbarActivityMessage];

                if (failureCount > 0) {
                    if (nodeCount == 1) {                        
                        [self alert:@"There was a problem creating your Cloud Server." request:[notification.userInfo objectForKey:@"request"]];
                    } else if (failureCount == nodeCount) {
                        [self alert:@"There was a problem creating your Cloud Servers. To see details for all failures, go to API Logs." request:[notification.userInfo objectForKey:@"request"]];
                    } else {
                        [self alert:[NSString stringWithFormat:@"There was a problem creating %i of your Cloud Servers. To see details for all failures, go to API Logs.", failureCount] request:[notification.userInfo objectForKey:@"request"]];
                    }
                }
            }
            
        }];
        
        id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"createServerFailed" object:server 
                                                                      queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification)
        {
            failureCount++;
            
            // if fail count + success count == node count, show an alert that
            // says how many failed.  if fail count > 1, tell the user to view
            // API Logs to see all of the failures.  Details button should show
            // the first failure
            
            if (nodeCount - successCount - failureCount == 0) {
                [serversViewController hideToolbarActivityMessage];
            } else {
                if (nodeCount - successCount - failureCount == 1) {
                    [serversViewController showToolbarActivityMessage:@"Creating 1 server..."];
                } else {
                    [serversViewController showToolbarActivityMessage:[NSString stringWithFormat:@"Creating %i servers...", nodeCount - successCount - failureCount]];
                }
            }
            
            if (failureCount + successCount == nodeCount) {
                [serversViewController hideToolbarActivityMessage];

                if (failureCount > 0) {
                    if (nodeCount == 1) {
                        [self alert:@"There was a problem creating your Cloud Server." request:[notification.userInfo objectForKey:@"request"]];
                    } else if (failureCount == nodeCount) {
                        [self alert:@"There was a problem creating your Cloud Servers. To see details for all failures, go to API Logs." request:[notification.userInfo objectForKey:@"request"]];
                    } else {
                        [self alert:[NSString stringWithFormat:@"There was a problem creating %i of your Cloud Server. To see details for all failures, go to API Logs.", failureCount] request:[notification.userInfo objectForKey:@"request"]];
                    }
                }
            }
            
        }];
                    
        [createServerObservers addObject:success];
        [createServerObservers addObject:failure];

        [server release];
    }
    
    // since UIProgressBar looks like crap on a non-default tint UIToolbar,
    // we'll just use text and count down as the servers are created
    if (nodeCount == 1) {
        [serversViewController showToolbarActivityMessage:@"Creating server..."];
    } else {
        [serversViewController showToolbarActivityMessage:[NSString stringWithFormat:@"Creating %i servers...", nodeCount]];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    successCount = 0;
    failureCount = 0;
    
    nodeCount = 1;
    self.navigationItem.title = @"Add Server";
    
    serverCountSlider = [[UISlider alloc] init];
    flavorSlider = [[UISlider alloc] init];
    
    [self addCancelButton];
    [self addSaveButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(98.0, 13.0, 400.0, 24.0)];
    } else {
        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, 13.0, 222.0, 24.0)];
    }
    nameTextField.delegate = self;
    nameTextField.font = [UIFont systemFontOfSize:17.0];
    nameTextField.textColor = [UIColor value1DetailTextLabelColor];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.textAlignment = UITextAlignmentRight;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    nameTextField.placeholder = @"Ex: web-server";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        serverNumbersLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 15.5, 458.0, 18.0)];
    } else {
        serverNumbersLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 15.5, 280.0, 18.0)];
    }
    serverNumbersLabel.font = [UIFont systemFontOfSize:17.0];
    serverNumbersLabel.textColor = [UIColor value1DetailTextLabelColor];
    serverNumbersLabel.backgroundColor = [UIColor clearColor];
    serverNumbersLabel.textAlignment = UITextAlignmentRight;
    serverNumbersLabel.text = @"";    
    
    NSMutableArray *allPlugins = [[NSMutableArray alloc] initWithArray:[AddServerPluginHandler plugins]];
    for (id <AddServerPlugin> plugin in [AddServerPluginHandler plugins]) {
        if ([plugin pluginShouldAppear]) {
            [plugin pluginWillAppear];
        } else {
            [allPlugins removeObject:plugin];
        }
    }
    
    plugins = [[NSArray alloc] initWithArray:allPlugins];
    [allPlugins release];
    
    createServerObservers = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload {
    for (id observer in createServerObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    RateLimit *limit = [OpenStackRequest createServerLimit:self.account];
    maxServers = limit.remaining;
    
    // load defaults for flavor and image.  if no default set yet, use the smallest flavor
    // and the newest Ubuntu
    
    if (account.lastUsedFlavorId == 0) {
        flavorIndex = 0;
        account.lastUsedFlavorId = [[self.account.sortedFlavors objectAtIndex:0] identifier];
    } else {
        for (int i = 0; i < [self.account.sortedFlavors count]; i++) {
            Flavor *flavor = [self.account.sortedFlavors objectAtIndex:i];
            if (flavor.identifier == account.lastUsedFlavorId) {
                flavorIndex = i;
                flavorSlider.value = ((flavorIndex * 1.0) / ([self.account.sortedFlavors count] - 1));
                flavorLabel.text = [NSString stringWithFormat:@"%i MB RAM, %i GB Disk", flavor.ram, flavor.disk];
            }
        }
    }
    
    if (account.lastUsedImageId == 0) {
        // select the newest ubuntu as a default.  if there's not a newest ubuntu, select the 
        // first image id
        NSMutableArray *ubuntus = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [self.account.sortedImages count]; i++) {
            Image *image = [self.account.sortedImages objectAtIndex:i];
            if ([[image logoPrefix] isEqualToString:@"ubuntu"]) {
                [ubuntus addObject:image];
            }
        }
        
        if ([ubuntus count] > 0) {
            selectedImage = [ubuntus lastObject];
        } else {
            selectedImage = [self.account.sortedImages objectAtIndex:0];
        }
        account.lastUsedImageId = selectedImage.identifier;
        [ubuntus release];
        
    } else {
        selectedImage = [self.account.images objectForKey:[NSNumber numberWithInt:account.lastUsedImageId]];
    }
    
    [self.tableView reloadData]; // force the image name to show up
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize = CGSizeMake(260.0, 9000.0f);
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodeCount) {
        return tableView.rowHeight + flavorSlider.frame.size.height + 3.0;
    } else if (indexPath.section == kNodeDetails) {
        if (indexPath.row == kSize) {
            return tableView.rowHeight + serverCountSlider.frame.size.height + 3.0;
        } else if (indexPath.row == kImageRow) {
            CGSize size = [selectedImage.name sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(220.0, 9000.0f) lineBreakMode:UILineBreakModeWordWrap];
            CGFloat result = size.height;
            if (result > 22.0) {
                result += 22.0;
            }
            return MAX(tableView.rowHeight, result);
        } else {
            return tableView.rowHeight;
        }
    } else {
        return tableView.rowHeight;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2 + [plugins count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kNodeCount) {
        return 1;
    } else if (section == kNodeDetails) {
        return 3;
    } else {
        id <AddServerPlugin> plugin = [plugins objectAtIndex:section - 2];
        return [plugin tableView:tableView numberOfRowsInSection:section];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kNodeCount) {
        if (maxServers == 1) {
            return @"With your current API rate limit, you can create one node at a time.";
        } else {
            //return [NSString stringWithFormat:@"With your current API rate limit, you can create up to %i Cloud Servers at a time.", maxServers];
            return [NSString stringWithFormat:@"With your current API rate limit, you can create up to %i servers at a time.", maxServers];
        }
    } else if (section == kNodeDetails) {
        return [self.account.provider isRackspace] ? @"Please refer to rackspacecloud.com for Cloud Servers pricing." : @"";
    } else {
        id <AddServerPlugin> plugin = [plugins objectAtIndex:section - 2];
        return [plugin tableView:tableView titleForFooterInSection:section];
    }
}

- (void)serverCountSliderMoved:(id)sender {
    nodeCount = (NSInteger)(serverCountSlider.value * maxServers);
    if (nodeCount == 0 || nodeCount == 1) {
        nodeCount = 1;
        serverCountLabel.text = @"1 server";
        serverNumbersLabel.text = @"";
        nameTextField.placeholder = @"Ex: web-server";
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nameTextField.frame = CGRectMake(98.0, 13.0, 400.0, 24.0);
        } else {
            nameTextField.frame = CGRectMake(79.0, 13.0, 222.0, 24.0);
        }
        
    } else {
        serverCountLabel.text = [NSString stringWithFormat:@"%i servers", nodeCount];
        if (nodeCount == 2) {
            serverNumbersLabel.text = @"[1,2]";
        } else {
            serverNumbersLabel.text = [NSString stringWithFormat:@"[1..%i]", nodeCount];
        }

        nameTextField.placeholder = @"";

        // move the text field to make room for the numbers label
        CGSize size = [serverNumbersLabel.text sizeWithFont:serverNumbersLabel.font constrainedToSize:CGSizeMake(280.0, 900.0f)];        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nameTextField.frame = CGRectMake(98.0, 13.0, 400.0 - size.width, 24.0);
        } else {
            nameTextField.frame = CGRectMake(79.0, 13.0, 222.0 - size.width, 24.0);
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView serverCountCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ServerCountCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 280.0, 20.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabel.frame = CGRectMake(41.0, 13.0, 458.0, 20.0);
        }
        textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        textLabel.text = @"Cloud Servers";
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:textLabel];
        [textLabel release];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            serverCountSlider.frame = CGRectMake(41.0, 38.0, 458.0, serverCountSlider.frame.size.height);
        } else {
            serverCountSlider.frame = CGRectMake(20.0, 38.0, 280.0, serverCountSlider.frame.size.height);
        }
        [serverCountSlider addTarget:self action:@selector(serverCountSliderMoved:) forControlEvents:UIControlEventValueChanged];
        
        [cell addSubview:serverCountSlider];
        serverCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 280.0, 18.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            serverCountLabel.frame = CGRectMake(41.0, 14.0, 458.0, 18.0);
        }
        serverCountLabel.font = [UIFont systemFontOfSize:17.0];
        serverCountLabel.textColor = [UIColor value1DetailTextLabelColor];
        serverCountLabel.backgroundColor = [UIColor clearColor];
        serverCountLabel.textAlignment = UITextAlignmentRight;
        [cell addSubview:serverCountLabel];
    }

    if (nodeCount == 1) {
        serverCountLabel.text = @"1 server";
    } else {
        serverCountLabel.text = [NSString stringWithFormat:@"%i servers", nodeCount];
    }
    
    return cell;
}

- (void)flavorSliderFinished:(id)sender {
    flavorIndex = MIN([self.account.sortedFlavors count] - 1, (NSInteger)[self.account.sortedFlavors count] * flavorSlider.value);
    Flavor *flavor = [self.account.sortedFlavors objectAtIndex:flavorIndex];
    flavorLabel.text = [NSString stringWithFormat:@"%i MB RAM, %i GB Disk", flavor.ram, flavor.disk];
    self.account.lastUsedFlavorId = flavor.identifier;    
    
    NSMutableArray *accountArr = [NSMutableArray arrayWithArray:[OpenStackAccount accounts]];
    for (int i = 0; i < [accountArr count]; i++) {
        OpenStackAccount *anAccount = [accountArr objectAtIndex:i];
        if ([self.account.uuid isEqualToString:anAccount.uuid]) {            
            [accountArr replaceObjectAtIndex:i withObject:self.account];
        }
    }
    [self.account persist];
    
}

- (void)flavorSliderMoved:(id)sender {
    flavorIndex = MIN([self.account.sortedFlavors count] - 1, (NSInteger)[self.account.sortedFlavors count] * flavorSlider.value);
    Flavor *flavor = [self.account.sortedFlavors objectAtIndex:flavorIndex];
    flavorLabel.text = [NSString stringWithFormat:@"%i MB RAM, %i GB Disk", flavor.ram, flavor.disk];
    self.account.lastUsedFlavorId = flavor.identifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView sizeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SizeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 280.0, 20.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabel.frame = CGRectMake(41.0, 13.0, 458.0, 20.0);
        }
        textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        textLabel.text = @"Size";
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:textLabel];
        [textLabel release];
        
        flavorSlider.frame = CGRectMake(20.0, 38.0, 280.0, flavorSlider.frame.size.height);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            flavorSlider.frame = CGRectMake(41.0, 38.0, 458.0, flavorSlider.frame.size.height);
        }
        [flavorSlider addTarget:self action:@selector(flavorSliderMoved:) forControlEvents:UIControlEventValueChanged];
        [flavorSlider addTarget:self action:@selector(flavorSliderFinished:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:flavorSlider];
        flavorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 280.0, 18.0)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            flavorLabel.frame = CGRectMake(41.0, 14.0, 458.0, 18.0);
        }
        flavorLabel.font = [UIFont systemFontOfSize:17.0];
        flavorLabel.textColor = [UIColor value1DetailTextLabelColor];
        flavorLabel.backgroundColor = [UIColor clearColor];
        flavorLabel.textAlignment = UITextAlignmentRight;
        [cell addSubview:flavorLabel];
    }
    
    Flavor *flavor = [self.account.sortedFlavors objectAtIndex:flavorIndex];
    flavorLabel.text = [NSString stringWithFormat:@"%i MB RAM, %i GB Disk", flavor.ram, flavor.disk];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView nameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NameCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Name";
        [cell addSubview:nameTextField];
        [cell addSubview:serverNumbersLabel];
    }    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kNodeCount) {
        return [self tableView:tableView serverCountCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kNodeDetails) {
        if (indexPath.row == kName) {
            return [self tableView:tableView nameCellForRowAtIndexPath:indexPath];
        } else if (indexPath.row == kSize) {
            return [self tableView:tableView sizeCellForRowAtIndexPath:indexPath];
        } else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
                cell.textLabel.numberOfLines = 0;       
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.detailTextLabel.numberOfLines = 0;
                cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
            }
            cell.textLabel.text = @"Image";
            cell.detailTextLabel.text = self.selectedImage.name;
            
            return cell;
        }
    } else {
        id <AddServerPlugin> plugin = [plugins objectAtIndex:indexPath.section - 2];
        return [plugin tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kNodeDetails && indexPath.row == kImageRow) {        
        SimpleImagePickerViewController *vc = [[SimpleImagePickerViewController alloc] initWithNibName:@"SimpleImagePickerViewController" bundle:nil];
        vc.mode = kModeChooseImage;
        vc.account = self.account;
        vc.selectedImageId = selectedImage.identifier;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Error Alert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // details button
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            logEntryModalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        }                
        [self.serversViewController presentModalViewController:logEntryModalViewController animated:YES];
        [logEntryModalViewController release];
    }
}

- (void)alert:(NSString *)message request:(OpenStackRequest *)request {
    if (request.responseStatusCode == 0) {
        [self failOnBadConnection];
    } else {
        logEntryModalViewController = [[LogEntryModalViewController alloc] initWithNibName:@"LogEntryModalViewController" bundle:nil];
        logEntryModalViewController.logEntry = [[APILogEntry alloc] initWithRequest:request];
        logEntryModalViewController.requestDescription = [logEntryModalViewController.logEntry requestDescription];
        logEntryModalViewController.responseDescription = [logEntryModalViewController.logEntry responseDescription];
        logEntryModalViewController.requestMethod = [logEntryModalViewController.logEntry requestMethod];
        logEntryModalViewController.url = [[logEntryModalViewController.logEntry url] description];
        
        // present an alert with a Details button to show the API log entry
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Details", nil];
        [alert show];
        [alert release];        
    }
}
 
#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [serverCountSlider release];
    [flavorSlider release];
    [nameTextField release];
    [serverNumbersLabel release];
    [selectedImage release];
    [plugins release];
    [serversViewController release];
    [createServerObservers release];
    [accountHomeViewController release];
    [super dealloc];
}

@end
