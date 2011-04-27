//
//  AddObjectViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddObjectViewController.h"
#import "UIViewController+Conveniences.h"
#import "AddFolderViewController.h"
#import "AddFileViewController.h"

#define kFolder 0
#define kFile 1

@implementation AddObjectViewController

@synthesize account, container, folder, folderViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add Object";
    [self addCancelButton];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kFolder) {
        return @"A folder is represented as a zero byte directory marker object in this container.";
    } else if (section == kFile) {
        return [NSString stringWithFormat:@"Files can be added from your %@ or synced from iTunes.", [[UIDevice currentDevice] model]];
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    if (indexPath.section == kFolder) {
        cell.textLabel.text = @"Add a Folder";
        cell.imageView.image = [UIImage imageNamed:@"folder-icon.png"];
    } else if (indexPath.section == kFile) {
        cell.textLabel.text = @"Add a File";
        NSString *emptyPath = [[NSBundle mainBundle] pathForResource:@"empty-file" ofType:@""];
        UIDocumentInteractionController *udic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:emptyPath]];
        cell.imageView.image = [udic.icons objectAtIndex:0]; //[UIImage imageNamed:@"file-icon.png"];        
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kFolder) {
        AddFolderViewController *vc = [[AddFolderViewController alloc] initWithNibName:@"AddFolderViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.folder = self.folder;
        vc.folderViewController = self.folderViewController;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (indexPath.section == kFile) {
        AddFileViewController *vc = [[AddFileViewController alloc] initWithNibName:@"AddFileViewController" bundle:nil];
        vc.account = self.account;
        vc.container = self.container;
        vc.folder = self.folder;
        vc.folderViewController = self.folderViewController;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    [super dealloc];
}

@end
