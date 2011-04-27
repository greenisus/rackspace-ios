//
//  MediaViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaViewController.h"
#import "Container.h"
#import "StorageObject.h"


@implementation MediaViewController

@synthesize object, container;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = object.name;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];        
    NSString *shortPath = [NSString stringWithFormat:@"/%@/%@", self.container.name, self.object.fullPath];
    NSString *filePath = [documentsDirectory stringByAppendingString:shortPath];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [[player view] setFrame:[self.view bounds]];  // frame must match parent view
    
    // private API, not App Store safe
//    if ([player respondsToSelector:@selector(setAllowsWirelessPlayback:)]) {
//        [player performSelector:@selector(setAllowsWirelessPlayback:) withObject:[NSNumber numberWithBool:YES]];
//    }

    // public way that's App Store safe, works in iOS 4.3+
    if ([player respondsToSelector:@selector(setAllowsAirPlay:)]) {
        [player performSelector:@selector(setAllowsAirPlay:) withObject:[NSNumber numberWithBool:YES]];
    }
    
    [self.view addSubview:[player view]];
    //player.fullscreen = YES;
    //player.controlStyle = MPMovieControlStyleFullscreen;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification) 
    {
        player.initialPlaybackTime = -1;
        [player stop];
        //[self.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
    
    self.view = player.view;
    
    [player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [player stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
    [container release];
    [object release];
    [super dealloc];
}


@end
