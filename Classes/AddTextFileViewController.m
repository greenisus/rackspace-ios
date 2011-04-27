//
//  AddTextFileViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddTextFileViewController.h"
#import "UIViewController+Conveniences.h"
#import "UploadGenericFileViewController.h"


@implementation AddTextFileViewController

@synthesize account, container, folder, folderViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [textView becomeFirstResponder];
    [self addDoneButton];
    self.navigationItem.title = @"Add Text File";
    textView.font = [UIFont fontWithName:@"Courier" size:16.0];
}

- (void)doneButtonPressed:(id)sender {
    UploadGenericFileViewController *vc = [[UploadGenericFileViewController alloc] initWithNibName:@"UploadGenericFileViewController" bundle:nil];
    vc.account = self.account;
    vc.container = self.container;
    vc.folder = self.folder;
    vc.folderViewController = self.folderViewController;
    vc.data = [textView.text dataUsingEncoding:NSUTF8StringEncoding];
    vc.contentTypeEditable = YES;
    vc.format = @".txt";
    vc.contentType = @"text/plain";
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)dealloc {
    [account release];
    [container release];
    [folder release];
    [folderViewController release];
    [super dealloc];
}


@end
