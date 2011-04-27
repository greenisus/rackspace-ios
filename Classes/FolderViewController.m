//
//  FolderViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 12/15/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "FolderViewController.h"
#import "OpenStackAccount.h"
#import "Container.h"
#import "Folder.h"
#import "StorageObject.h"
#import "StorageObjectViewController.h"
#import "ContainerDetailViewController.h"
#import "AccountManager.h"
#import "ActivityIndicatorView.h"
#import "ContainersViewController.h"
#import "UIViewController+Conveniences.h"
#import "AddObjectViewController.h"
#import "OpenStackAppDelegate.h"
#import "RootViewController.h"


@implementation FolderViewController

@synthesize account, container, folder, containersViewController, selectedContainerIndexPath, contentsLoaded, parentFolderViewController, selectedFolderIndexPath;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addAddButton];
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this folder?  This operation cannot be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Folder" otherButtonTitles:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (folder.name && ![@"" isEqualToString:folder.name]) {
        self.navigationItem.title = self.folder.name;
    } else {
        self.navigationItem.title = self.container.name;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.folder) {
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:@"Loading..."] text:@"Loading..."];
        [activityIndicatorView addToView:self.view];
        
        [self.account.manager getObjects:self.container];
        
    }

    successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"getObjectsSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {           
           self.folder = self.container.rootFolder;
           contentsLoaded = YES;
           [self.tableView reloadData];                           
           [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
           [activityIndicatorView removeFromSuperviewAndRelease];
       }];

    failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"renameServerSucceeded" object:self.container
                                                                         queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
       {
           [self.tableView reloadData];                           
           [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
           [activityIndicatorView removeFromSuperviewAndRelease];
       }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!(folder.name && ![@"" isEqualToString:folder.name])) {
        [self.containersViewController.tableView deselectRowAtIndexPath:self.selectedContainerIndexPath animated:YES];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(contentsLoaded ? 1 : 0, [folder.objects count] + [folder.folders count]);
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([folder.objects count] + [folder.folders count] == 0) {
        aTableView.scrollEnabled = NO;
        aTableView.allowsSelection = NO;
        return aTableView.frame.size.height;
    } else {
        aTableView.scrollEnabled = YES;
        aTableView.allowsSelection = YES;
        return aTableView.rowHeight;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([folder.objects count] + [folder.folders count] == 0) {
        if ([self.container.rootFolder isEqual:self.folder]) {
            return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-files.png"] title:@"No Files or Folders" subtitle:@"Tap the + button to add a new file or folder."];
        } else {
            return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-files.png"] title:@"No Files or Folders" subtitle:@"Tap the + button to add a new file or folder." deleteButtonTitle:@"Delete Folder" deleteButtonSelector:@selector(deleteButtonPressed:)];
        }
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        id item = [self.folder.sortedContents objectAtIndex:indexPath.row];    
        cell.textLabel.text = [item name];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([[item class] isEqual:[Folder class]]) {
            
            cell.imageView.image = [UIImage imageNamed:@"folder-icon.png"];
            
            NSString *folderString = @"";
            NSString *objectString = @"";
            if ([[item folders] count] > 1) {
                folderString = [NSString stringWithFormat:@"%i folders, ", [[item folders] count]];
            } else if ([[item folders] count] > 0) {
                folderString = @"1 folder, ";
            }
            if ([[item objects] count] != 1) {
                objectString = [NSString stringWithFormat:@"%i objects", [[item objects] count]];
            } else if ([[item objects] count]) {
                objectString = @"1 object";
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", folderString, objectString];
        } else if ([[item class] isEqual:[StorageObject class]]) {
            StorageObject *object = item;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, object.fullPath];
            NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];

            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                UIDocumentInteractionController *udic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                cell.imageView.image = [udic.icons objectAtIndex:0];
            } else {
                NSString *emptyPath = [[NSBundle mainBundle] pathForResource:@"empty-file" ofType:@""];
                UIDocumentInteractionController *udic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:emptyPath]];
                cell.imageView.image = [udic.icons objectAtIndex:0]; //[UIImage imageNamed:@"file-icon.png"];        
            }
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [item humanizedBytes], [item contentType]];
        }
        
        return cell;
    }        
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([folder.objects count] + [folder.folders count] > 0) {
        id item = [self.folder.sortedContents objectAtIndex:indexPath.row];        
        if ([[item class] isEqual:[Folder class]]) {
            FolderViewController *vc = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
            vc.account = self.account;
            vc.container = self.container;
            vc.folder = item;
            vc.contentsLoaded = YES;
            vc.selectedFolderIndexPath = indexPath;
            vc.parentFolderViewController = self;
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        } else if ([[item class] isEqual:[StorageObject class]]) {
            StorageObjectViewController *vc = [[StorageObjectViewController alloc] initWithNibName:@"StorageObjectViewController" bundle:nil];
            vc.account = self.account;
            vc.container = self.container;
            vc.folder = self.folder;
            vc.object = item;
            vc.folderViewController = self;
            vc.selectedIndexPath = indexPath;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.navigationController presentPrimaryViewController:vc];
                OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
                if (app.rootViewController.popoverController != nil) {
                    [app.rootViewController.popoverController dismissPopoverAnimated:YES];
                }
            } else {
                [self.navigationController pushViewController:vc animated:YES];
            }
            [vc release];
        }
    }
}

#pragma mark -
#pragma mark Buttons

- (void)addButtonPressed:(id)sender {
    AddObjectViewController *vc = [[AddObjectViewController alloc] initWithNibName:@"AddObjectViewController" bundle:nil];
    vc.account = self.account;
    vc.container = self.container;
    vc.folder = self.folder;
    vc.folderViewController = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        OpenStackAppDelegate *app = [[UIApplication sharedApplication] delegate];
        if (app.rootViewController.popoverController != nil) {
            [app.rootViewController.popoverController dismissPopoverAnimated:YES];
        }
    }
    [self presentModalViewControllerWithNavigation:vc animated:YES];
    [vc release];
}

- (void)deleteButtonPressed:(id)sender {
    [deleteActionSheet showInView:self.view];    
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)deleteFolderRow {
    [self.parentFolderViewController.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedFolderIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        StorageObject *object = [[StorageObject alloc] init];
        object.name = object.fullPath = [self.folder fullPath];
        
        NSString *activityMessage = @"Deleting folder...";
        activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
        [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];    

        [self.account.manager deleteObject:self.container object:object];
        
        
        successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteObjectSucceeded" object:object
                                                                             queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            if (self.folder.parent) {
                [self.folder.parent.folders removeObjectForKey:self.folder.name];
            } else {
                [self.container.rootFolder.folders removeObjectForKey:self.folder.name];
            }
            [self.account persist];

            [activityIndicatorView removeFromSuperviewAndRelease];
            [self.navigationController popViewControllerAnimated:YES];

            if (self.folder.parent) {
                if ([self.folder.parent.folders count] + [self.folder.parent.objects count] == 0) {
                    [self.parentFolderViewController.tableView reloadData];
                } else {
                    [self.parentFolderViewController.tableView selectRowAtIndexPath:selectedFolderIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(deleteFolderRow) userInfo:nil repeats:NO];
                }
            } else {
                if ([self.container.rootFolder.folders count] + [self.container.rootFolder.objects count] == 0) {
                    [self.parentFolderViewController.tableView reloadData];
                } else {
                    [self.parentFolderViewController.tableView selectRowAtIndexPath:selectedFolderIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(deleteFolderRow) userInfo:nil repeats:NO];
                }
            }
            
            
            
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [object release];
        }];
        
        failureObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteObjectFailed" object:object
                                                                             queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
        {
            [activityIndicatorView removeFromSuperviewAndRelease];
            [self alert:@"There was a problem deleting this folder." request:[notification.userInfo objectForKey:@"request"]];
            [[NSNotificationCenter defaultCenter] removeObserver:failureObserver];
            [object release];
        }];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [folder release];
    [containersViewController release];
    [selectedContainerIndexPath release];
    [deleteActionSheet release];
    [parentFolderViewController release];
    [selectedFolderIndexPath release];
    [super dealloc];
}


@end

