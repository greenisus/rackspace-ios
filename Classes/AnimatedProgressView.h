//
//  AnimatedProgressView.h
//  OpenStack
//
//  Created by Mike Mayo on 10/29/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>
#import "ASIProgressDelegate.h"


@interface AnimatedProgressView : UIProgressView {
    NSTimer *progressTimer;
    CGFloat targetProgress;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
