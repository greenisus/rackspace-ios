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
        
    [[GANTracker sharedTracker] trackEvent:category action:action label:nil value:-1 withError:nil];
}

void TrackViewController(UIViewController *vc){
        
    NSError *error;
    
    NSMutableString *className = [NSMutableString stringWithUTF8String:class_getName([vc class])];
    [className replaceOccurrencesOfString:@"ViewController" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [className length])];
    [className insertString:@"/" atIndex:0];
    
    [[GANTracker sharedTracker] trackPageview:className withError:&error];
}

void DispatchAnalytics(){
    
    [[GANTracker sharedTracker] dispatch]; 
}