//
//  StorageObjectViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/19/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "StorageObjectViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "AccountManager.h"
#import "AnimatedProgressView.h"
#import "UIViewController+Conveniences.h"
#import "MediaViewController.h"
#import "FolderViewController.h"
#import "UIColor+MoreColors.h"
#import "OpenStackAppDelegate.h"

#define kDetails 0
#define kMetadata -1

// TODO: use etag to reset download
// TODO: try downloading directly to the file to save memory.  don't use object.data

/*
 Name                           whatever.txt
 Full Path
 Size                           123 KB
 Content Type                   text/plain
 
 Metadata
 Key                            Value -> tap goes to a metadata item VC to edit or delete
 Key                            Value
 Add Metadata... (if max not already reached)
 
 CDN URL sections (action sheet to copy, open in safari, and email link)
 
 Download File (if downloaded, Open File and Mail File as Attachment)
 "After you download the file, you'll be able to attempt to open it and mail is as an attachment."
 
 Delete Object
 */

@implementation StorageObjectViewController

@synthesize account, container, folder, object, tableView, folderViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setBackgroundView {
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];        
//    NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, self.object.fullPath];
//    NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
    UIImageView *logo;

    // icons are too small, but leaving this in case larger ones show up in iOS later
//    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        UIDocumentInteractionController *udic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
//        NSLog(@"icons count: %i", [udic.icons count]);
//        logo = [[UIImageView alloc] initWithImage:[udic.icons lastObject]];
//    } else {
        logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloudfiles-large.png"]];
//    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *backgroundContainer = [[UIView alloc] init];
        backgroundContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundContainer.backgroundColor = [UIColor iPadTableBackgroundColor];
        logo.contentMode = UIViewContentModeScaleAspectFit;
        logo.frame = CGRectMake(100.0, 100.0, 1000.0, 1000.0);
        logo.alpha = 0.5;        
        [backgroundContainer addSubview:logo];
        [logo release];
        tableView.backgroundView = backgroundContainer;
        [backgroundContainer release];
    } else {        
        logo.contentMode = UIViewContentModeScaleAspectFit;
        logo.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
        tableView.backgroundView = logo;
        [logo release];
    }
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this file?  This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete File" otherButtonTitles:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = object.name;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];        
    NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, self.object.fullPath];
    NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    fileDownloaded = [fileManager fileExistsAtPath:filePath];
    
    downloadProgressView = [[AnimatedProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect rect = downloadProgressView.frame;
        rect.size.width = 440.0;
        downloadProgressView.frame = rect;
    }
    
    [self setBackgroundView];
    if (self.container.cdnEnabled) {
        cdnURLSection = 1;
        actionsSection = 2;
        deleteSection = 3;
    } else {
        cdnURLSection = -1;
        actionsSection = 1;
        deleteSection = 2;
    }
    
    // let's see if we can tweet
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://post?message=test"];

    if ([app canOpenURL:twitterURL]) {
        cdnURLActionSheet = [[UIActionSheet alloc] initWithTitle:[[NSString stringWithFormat:@"%@/%@", self.container.cdnURL, self.object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Pasteboard", @"Open in Safari", @"Email Link to File", @"Tweet Link to File", nil];
    } else {
        cdnURLActionSheet = [[UIActionSheet alloc] initWithTitle:[[NSString stringWithFormat:@"%@/%@", self.container.cdnURL, self.object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Pasteboard", @"Open in Safari", @"Email Link to File", nil];
    }
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.container.cdnEnabled ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kDetails) {
        return 4;
    } else if (section == kMetadata) {
        return 1 + [object.metadata count];
    } else if (section == cdnURLSection) {
        return 1;
    } else if (section == actionsSection) {
        return fileDownloaded ? 2 : 1;
    } else if (section == deleteSection) {
        return 1;
    } else {
        return 1;
    }
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == actionsSection) {
        return @"After you download the file, you'll be able to attempt to open it and mail it as an attachment.";
    } else {
        return @"";
    }
}
*/

- (CGFloat)findLabelHeight:(NSString*)text font:(UIFont *)font {
    CGSize textLabelSize;    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // 616, 678
        textLabelSize = CGSizeMake(596.0, 9000.0f);
    } else {
        textLabelSize = CGSizeMake(280.0, 9000.0f);
    }
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeCharacterWrap];
    return stringSize.height;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = aTableView.rowHeight;
    
    if (indexPath.section == cdnURLSection) {
        result = 22.0 + [self findLabelHeight:[[NSString stringWithFormat:@"%@/%@", self.container.cdnURL, self.object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] font:[UIFont systemFontOfSize:18.0]];
    } else if (indexPath.section == kDetails && indexPath.row == 1) {
        CGSize textLabelSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabelSize = CGSizeMake(537.0, 9000.0f);
        } else {
            textLabelSize = CGSizeMake(221.0, 9000.0f);
        }
        CGSize stringSize = [object.fullPath sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
        return 22.0 + stringSize.height;
    } else if (indexPath.section == kDetails && indexPath.row == 0) {
        CGSize textLabelSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            textLabelSize = CGSizeMake(537.0, 9000.0f);
        } else {
            textLabelSize = CGSizeMake(221.0, 9000.0f);
        }
        CGSize stringSize = [object.name sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
        return 22.0 + stringSize.height;
    }
    
    return MAX(aTableView.rowHeight, result);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.93];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    
    // Configure the cell...
    if (indexPath.section == kDetails) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = nil;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = object.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Full Path";
            cell.detailTextLabel.text = object.fullPath;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [object humanizedBytes];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = object.contentType;
        }
    } else if (indexPath.section == kMetadata) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
        if (indexPath.row == [object.metadata count]) {
            cell.textLabel.text = @"Add Metadata";
            cell.detailTextLabel.text = @"";
        } else {
            NSString *key = [[object.metadata allKeys] objectAtIndex:indexPath.row];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = [object.metadata objectForKey:key];
        }
    } else if (indexPath.section == cdnURLSection) {
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@/%@", self.container.cdnURL, self.object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else if (indexPath.section == actionsSection) {
        cell.accessoryView = nil;
        if (performingAction) {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }

        if (indexPath.row == 0) {
            if (fileDownloaded) {
                cell.textLabel.text = @"Open File";
            } else {
                if (fileDownloading) {
                    cell.accessoryView = downloadProgressView;
                    // TODO: if you leave this view while downloading, there's EXC_BAD_ACCESS
                    cell.textLabel.text = @"Downloading";
                } else {
                    cell.textLabel.text = @"Download File";
                }
            }
            cell.detailTextLabel.text = @"";
            
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Email File as Attachment";
            cell.detailTextLabel.text = @"";
        }
    } else if (indexPath.section == deleteSection) {
        cell.textLabel.text = @"Delete Object";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)reloadActionsTitleRow:(NSTimer *)timer {
    [[timer.userInfo objectForKey:@"tableView"] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:actionsSection]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == cdnURLSection) {
        [cdnURLActionSheet showInView:self.view];
    } else if (indexPath.section == actionsSection) {
        if (indexPath.row == 0) {
            if (fileDownloaded) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];        
                NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, self.object.fullPath];
                NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
                                
                UIDocumentInteractionController *vc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                vc.delegate = self;
                
                if (![vc presentPreviewAnimated:YES]) {
                    
                    if ([self.object isPlayableMedia]) {
                        MediaViewController *vc = [[MediaViewController alloc] initWithNibName:@"MediaViewController" bundle:nil];
                        vc.container = self.container;
                        vc.object = self.object;
                        [self.navigationController pushViewController:vc animated:YES];
                        [vc release];
                    } else {
                        [self alert:@"Error" message:@"This file could not be opened."];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                }
                
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:actionsSection] animated:YES];                
                
            } else {                
                // download the file
                fileDownloading = YES;
                [self.account.manager getObject:self.container object:self.object downloadProgressDelegate:self];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:actionsSection]] withRowAnimation:UITableViewRowAnimationNone];
                
            }
        } else if (indexPath.row == 1) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];        
            NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, self.object.fullPath];
            NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;		
            [vc setSubject:self.object.name];
            [vc addAttachmentData:data mimeType:self.object.contentType fileName:self.object.name];
            [vc setMessageBody:@"" isHTML:NO];    
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                vc.modalPresentationStyle = UIModalPresentationPageSheet;
            }                
            [self presentModalViewController:vc animated:YES];
            [vc release];        
        }
    } else if (indexPath.section == deleteSection) {
        [deleteActionSheet showInView:self.view];
    }
}

- (void)setProgress:(float)newProgress {
    [downloadProgressView setProgress:newProgress animated:YES];    
    if (newProgress >= 1.0) {
        fileDownloading = NO;
        fileDownloaded = YES;
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:actionsSection]] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:actionsSection]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark -
#pragma mark Document Interation Controller Delegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *) controller {
    return self.navigationController;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controllers {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:actionsSection] animated:YES];
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)deleteObjectRow {
    [self.folderViewController.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:deleteActionSheet]) {
        if (buttonIndex == 0) {
            // delete the file and pop out
            [self showToolbarActivityMessage:@"Deleting file..."];
            
            [self.account.manager deleteObject:self.container object:self.object];
            
            deleteSuccessObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteObjectSucceeded" object:self.object
                                                                                               queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [self hideToolbarActivityMessage];
                performingAction = NO;
                [self.folder.objects removeObjectForKey:self.object.name];
                [self.navigationController popViewControllerAnimated:YES];
                if ([self.folder.objects count] + [self.folder.folders count] == 0) {
                    [self.folderViewController.tableView reloadData];
                } else {
                    [self.folderViewController.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(deleteObjectRow) userInfo:nil repeats:NO];
                }
                [[NSNotificationCenter defaultCenter] removeObserver:deleteSuccessObserver];
            }];

            deleteFailureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteObjectFailed" object:self.object
                                                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
            {
                [self hideToolbarActivityMessage];
                performingAction = NO;
                [self alert:@"There was a problem deleting this file." request:[notification.userInfo objectForKey:@"request"]];

                [[NSNotificationCenter defaultCenter] removeObserver:deleteFailureObserver];

            }];
            
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:deleteSection];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ([actionSheet isEqual:cdnURLActionSheet]) {
        NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/%@", self.container.cdnURL, self.object.fullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        if (buttonIndex == 0) {
            // copy to pasteboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:[url description]];
        } else if (buttonIndex == 1) {
            // open in safari
            UIApplication *application = [UIApplication sharedApplication];
            if ([application canOpenURL:url]) {
                [application openURL:url];
            } else {
                [self alert:@"Error" message:[NSString stringWithFormat:@"This URL cannot be opened.\n%@", url]];
            }
        } else if (buttonIndex == 2) {
            // email link to file
            MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
            vc.mailComposeDelegate = self;		
            [vc setSubject:self.object.name];
            [vc setMessageBody:[url description] isHTML:NO];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                vc.modalPresentationStyle = UIModalPresentationPageSheet;
            }                
            [self presentModalViewController:vc animated:YES];
            [vc release];        
        } else if (buttonIndex == 3) {
            // tweet link to file
            UIApplication *app = [UIApplication sharedApplication];            
            NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=%@", [[url description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            if ([app canOpenURL:twitterURL]) {
                [app openURL:twitterURL];
            }
        }
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:cdnURLSection] animated:YES];
    }
}

#pragma mark -
#pragma mark Mail Composer Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:actionsSection] animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [downloadProgressView release];
    [deleteActionSheet release];
    [cdnURLActionSheet release];
    [tableView release];
    [folderViewController release];
    [super dealloc];
}


@end

