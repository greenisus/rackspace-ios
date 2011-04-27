//
//  ActivityIndicatorView.h
//  OpenStack
//
//  Created by Mike Mayo on 10/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <UIKit/UIKit.h>

#define kFadeTime 0.25
#define kFontSize 14.0
#define kCornerRadius 7
#define kSpinnerStyle UIActivityIndicatorViewStyleWhite

@class AnimatedProgressView;

@interface ActivityIndicatorView : UIView {
    AnimatedProgressView *progressView;
}

@property (retain) AnimatedProgressView *progressView;

+ (CGRect)frameForText:(NSString *)text;
+ (CGRect)frameForText:(NSString *)text withProgress:(BOOL)withProgress;
+ (void)addToView:(UIView *)view text:(NSString *)text;
- (id)initWithFrame:(CGRect)frame text:(NSString *)text;
- (id)initWithFrame:(CGRect)frame text:(NSString *)text withProgress:(BOOL)withProgress;

- (void)addToView:(UIView *)view scrollOffset:(CGFloat)offset;
- (void)addToView:(UIView *)view;
- (void)removeFromSuperviewAndRelease;

@end
