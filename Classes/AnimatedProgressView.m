//
//  AnimatedProgressView.m
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "AnimatedProgressView.h"

@implementation AnimatedProgressView

- (void)moveProgress {
    if (self.progress < targetProgress) {
        self.progress = MIN(self.progress + 0.01, targetProgress);
    } else {
        [progressTimer invalidate];
        progressTimer = nil;
    }
}

- (void)setProgress:(CGFloat)newProgress animated:(BOOL)animated {
    if (animated) {
        targetProgress = newProgress;
        if (progressTimer == nil) {
            progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveProgress) userInfo:nil repeats:YES];
        }
    } else {
        self.progress = newProgress;
    }
}

@end
