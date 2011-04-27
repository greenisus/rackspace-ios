//
//  ActivityIndicatorView.m
//  OpenStack
//
//  Created by Mike Mayo on 10/9/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "ActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimatedProgressView.h"


@implementation ActivityIndicatorView

@synthesize progressView;

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.superview.userInteractionEnabled = NO;
}

+ (CGSize) findLabelSize:(NSString*) text font:(UIFont *)font {
    return [text sizeWithFont:font constrainedToSize:CGSizeMake(300.0f, 9000.0f) lineBreakMode:UILineBreakModeWordWrap];
}

+ (CGRect)frameForText:(NSString *)text withProgress:(BOOL)withProgress {
    CGSize textSize = [ActivityIndicatorView findLabelSize:text font:[UIFont systemFontOfSize:kFontSize]];
    CGFloat baseWidth = 62.0;
    CGFloat width = baseWidth + textSize.width;
    CGFloat x = (320.0 - width) / 2;
    return CGRectMake(x, 146.0, width, withProgress ? 60.0 : 40.0);
}

+ (CGRect)frameForText:(NSString *)text {
    return [ActivityIndicatorView frameForText:text withProgress:NO];
}

+ (void)addToView:(UIView *)view text:(NSString *)text {
    UIActivityIndicatorView *activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:text] text:text];
    activityIndicatorView.alpha = 0.0;
    [view addSubview:activityIndicatorView];
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:kFadeTime];
    activityIndicatorView.alpha = 1.0;
    [UIView commitAnimations];
    
    [activityIndicatorView release];
}

- (void)addToView:(UIView *)view scrollOffset:(CGFloat)offset {
    self.alpha = 0.0;
    [view addSubview:self];
    
    self.center = view.center;

    // if it's a scroll view, move the frame down
    CGRect rect = self.frame;        
    rect.origin.y = 146.0;
    rect.origin.y += offset;
    self.frame = rect;
    
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:kFadeTime];
    self.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)addToView:(UIView *)view {
    [self addToView:view scrollOffset:0.0];
}

- (void)removeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    self.superview.userInteractionEnabled = YES;
    [self release];
}

- (void)removeFromSuperviewAndRelease {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:kFadeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeAnimationDidStop:finished:context:)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text withProgress:(BOOL)withProgress {
    if ((self = [super initWithFrame:frame])) {

        // border color
        self.backgroundColor = [UIColor colorWithRed:0.498 green:0.498 blue:0.498 alpha:1.0];
        self.layer.cornerRadius = kCornerRadius;
        
        CGRect contentFrame = CGRectInset(self.bounds, 2, 2);
        UIView *contentView = [[UIView alloc] initWithFrame:contentFrame];
        contentView.backgroundColor = [UIColor colorWithRed:0.198 green:0.198 blue:0.198 alpha:1.0];        
        contentView.layer.cornerRadius = kCornerRadius;
        [self addSubview:contentView];
        [self sendSubviewToBack:contentView];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:kSpinnerStyle];
        spinner.frame = CGRectMake(19.0, 10.0, 20.0, 20.0);
        [spinner startAnimating];
        [self addSubview:spinner];
        [spinner release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 5.0, contentFrame.size.width, 30.0)];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = text;
        label.font = [UIFont systemFontOfSize:kFontSize];
        [self addSubview:label];
        
        if (withProgress) {
            progressView = [[AnimatedProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            progressView.frame = CGRectMake(10.0, 40.0, frame.size.width - 20.0, 10.0);
            [self addSubview:progressView];
        }
        
        [label release];
        [contentView release];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text {
    return [self initWithFrame:frame text:text withProgress:NO];
}

- (void)dealloc {
    [progressView release];
    [super dealloc];
}


@end
