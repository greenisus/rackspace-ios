//
//  AboutViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "UIViewController+Conveniences.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"About";

    // show the actual version of the app in the about screen
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<version>" options:NSRegularExpressionCaseInsensitive error:nil];            
    NSRange range = [regex rangeOfFirstMatchInString:textView.text options:0 range:NSMakeRange(0, 100)];
    if (!NSEqualRanges(range, NSMakeRange(NSNotFound, 0))) {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:version];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [super dealloc];
}


@end
