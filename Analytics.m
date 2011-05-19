//
//  Constants.m
//  OpenStack
//
//  Created by Matthew Newberry on 05/18/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "Analytics.h"
#import <objc/runtime.h>

void TrackEvent(NSString *category, NSString *action){
        
    [[GANTracker sharedTracker] trackEvent:category action:action label:nil value:0 withError:nil];
 
    NSLog(@"EVENT - %@ - %@", category, action);
}

void TrackViewController(UIViewController *vc){
        
    NSMutableString *className = [NSMutableString stringWithUTF8String:class_getName([vc class])];
    [className replaceOccurrencesOfString:@"ViewController" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [className length])];
    
    [[GANTracker sharedTracker] trackPageview:className withError:nil];
    
    NSLog(@"PAGE VIEW - %@", className);
}

void DispatchAnalytics(){
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[GANTracker sharedTracker] dispatch]; 
    });
}