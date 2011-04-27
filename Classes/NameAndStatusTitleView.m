//
//  NameAndStatusTitleView.m
//  OpenStack
//
//  Created by Michael Mayo on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NameAndStatusTitleView.h"
#import "Server.h"
#import "Image.h"
#import "DDProgressView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat iPadXOffset;
static CGFloat logoXOffset;

@implementation NameAndStatusTitleView

@synthesize entity, statusTint, nameLabel, statusLabel, logoView, logoFilename, progressView;

static UIFont *nameFont = nil;
static UIFont *statusFont = nil;

+ (void)initialize {
    nameFont = [[UIFont boldSystemFontOfSize:17.0] retain];
    statusFont = [[UIFont boldSystemFontOfSize:13.0] retain];
}

- (id)initWithEntity:(id)e logoFilename:(NSString *)filename {
    
    self = [self initWithFrame:CGRectMake(0, 0, 1320, 64)];
    if (self) {
        self.entity = e;
        self.logoFilename = filename;
        
        logoXOffset = self.logoFilename ? 44 : 0;
        iPadXOffset = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 29 : 0;
        
        if (!([self.entity respondsToSelector:@selector(name)] && [self.entity respondsToSelector:@selector(status)] && [self.entity respondsToSelector:@selector(progress)] && [self.entity respondsToSelector:@selector(shouldBePolled)])) {
            @throw [NSException exceptionWithName:@"NameAndStatusEntityInvalidException" reason:@"entity for NameAndStatusTitleView should respond to name, status, progress, shouldBePolled" userInfo:nil];
        }

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        } else {
            self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // shadow
        self.clipsToBounds = NO;
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowRadius:2.0f];
        [self.layer setShadowOffset:CGSizeMake(1, 1)];
        [self.layer setShadowOpacity:0.8f];    
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0 + logoXOffset + iPadXOffset, 12.0, 654, 22)];
        
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = nameFont;
        nameLabel.text = [self.entity name];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [nameLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];        
        [nameLabel.layer setShadowRadius:1.0f];
        [nameLabel.layer setShadowOffset:CGSizeMake(1, 1)];
        [nameLabel.layer setShadowOpacity:1.0f];
        
        [self addSubview:nameLabel];
        
        CGSize statusSize = [[self.entity status] sizeWithFont:statusFont forWidth:300 lineBreakMode:UILineBreakModeCharacterWrap];
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0 + logoXOffset + iPadXOffset, 34.0, 200, statusSize.height)];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.textColor = [UIColor whiteColor];
        statusLabel.font = statusFont;
        statusLabel.text = [self.entity status];
        statusLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        statusLabel.numberOfLines = 0;
//        statusLabel.shadowOffset = CGSizeMake(0, 1.0);
//        statusLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];    
        [statusLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];        
        [statusLabel.layer setShadowRadius:1.0f];
        [statusLabel.layer setShadowOffset:CGSizeMake(1, 1)];
        [statusLabel.layer setShadowOpacity:1.0f];
        [self addSubview:statusLabel];
        
        self.statusTint = [[[UIView alloc] initWithFrame:self.frame] autorelease];
        self.statusTint.autoresizesSubviews = YES;
        self.statusTint.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.statusTint.alpha = 0.7;
        
        if ([@"ACTIVE" isEqualToString:[self.entity status]]) {
            self.statusTint.backgroundColor = [UIColor colorWithRed:0.314 green:0.588 blue:0.086 alpha:1.0];
        } else if ([self.entity shouldBePolled]) {
            self.statusTint.backgroundColor = [UIColor orangeColor];
        } else {
            self.statusTint.backgroundColor = [UIColor redColor];
        }
        
        [self addSubview:self.statusTint];
        [self sendSubviewToBack:self.statusTint];
        
        if (self.logoFilename) {
            logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.logoFilename]];
            logoView.frame = CGRectMake(12.0 + iPadXOffset, 14.0, logoView.frame.size.width, logoView.frame.size.height);
            logoView.clipsToBounds = NO;
            [logoView.layer setShadowColor:[[UIColor blackColor] CGColor]];
            [logoView.layer setShadowRadius:1.0f];
            [logoView.layer setShadowOffset:CGSizeMake(1, 1)];
            [logoView.layer setShadowOpacity:0.8f];
            [self addSubview:logoView];    
        }

        self.progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20)];
        self.progressView.progress = 0.0;
        [self.progressView.layer setShadowColor:[[UIColor blackColor] CGColor]];        
        [self.progressView.layer setShadowRadius:1.0f];
        [self.progressView.layer setShadowOffset:CGSizeMake(1, 1)];
        [self.progressView.layer setShadowOpacity:1.0f];
        
        [self addSubview:progressView];
    }
    return self;
}

- (id)initWithEntity:(id)e {
    return [self initWithEntity:e logoFilename:nil];
}

- (void)drawRect:(CGRect)rect {

    self.nameLabel.text = [self.entity name];

    if ([[self.entity status] isEqualToString:@"BUILD"]) {
        self.progressView.alpha = 1;
        self.statusLabel.text = @"Building";
        self.progressView.frame = CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20);
    } else if ([[self.entity status] isEqualToString:@"QUEUE_RESIZE"]) {
        self.progressView.alpha = 1;
        self.statusLabel.text = @"Resizing"; //@"Queueing";
        self.progressView.frame = CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20);
    } else if ([[self.entity status] isEqualToString:@"PREP_RESIZE"]) {
        self.progressView.alpha = 1;
        self.statusLabel.text = @"Resizing"; //@"Preparing";
        self.progressView.frame = CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20);
    } else if ([[self.entity status] isEqualToString:@"RESIZE"]) {
        self.progressView.alpha = 1;
        self.statusLabel.text = @"Resizing";
        self.progressView.frame = CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20);
    } else if ([[self.entity status] isEqualToString:@"VERIFY_RESIZE"]) {
        self.progressView.alpha = 0;
        self.statusLabel.text = @"Resize Complete";
    } else if ([[self.entity status] isEqualToString:@"REBUILD"]) {
        self.progressView.alpha = 1;
        self.statusLabel.text = @"Rebuilding";
        self.progressView.frame = CGRectMake(70 + logoXOffset + iPadXOffset, 37, 100, 20);
    } else if ([[self.entity status] isEqualToString:@"REBOOT"]) {
        self.progressView.alpha = 0;
        self.statusLabel.text = @"Rebooting";        
    } else if ([[self.entity status] isEqualToString:@"UNKNOWN"]) {
        self.progressView.alpha = 0;
        self.statusLabel.text = @"Unknown";
    } else if ([[self.entity status] isEqualToString:@"ACTIVE"]) {
        self.progressView.alpha = 0;
        self.statusLabel.text = @"Active";
    } else {
        self.progressView.alpha = 0;
        self.statusLabel.text = [self.entity status];
    }
    
    [self.progressView setProgress:[self.entity progress] / 100.0 animated:YES];
    
    if (![@"ACTIVE" isEqualToString:[self.entity status]]) {        

        if ([self.entity shouldBePolled]) {
            self.statusTint.backgroundColor = [UIColor orangeColor];
        } else {
            self.statusTint.backgroundColor = [UIColor redColor];
        }        
        
        if (![self.statusTint.layer animationForKey:@"animateOpacity"]) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.duration = 1.0;
            animation.repeatCount = HUGE_VALF; // repeat forever      
            animation.autoreverses = YES;	
            animation.fromValue = [NSNumber numberWithFloat:1.0]; 
            animation.toValue = [NSNumber numberWithFloat:0.5];
            [self.statusTint.layer addAnimation:animation forKey:@"animateOpacity"];
        }
    } else {
        
        
        [UIView animateWithDuration:1 animations:^{
            if ([@"ACTIVE" isEqualToString:[self.entity status]]) {
                [self.statusTint.layer removeAnimationForKey:@"animateOpacity"];
                self.statusTint.backgroundColor = [UIColor colorWithRed:0.314 green:0.588 blue:0.086 alpha:1.0];
            } else if ([self.entity shouldBePolled]) {
                self.statusTint.backgroundColor = [UIColor orangeColor];
            } else {
                self.statusTint.backgroundColor = [UIColor redColor];
            }
        }];
    }
    [super drawRect:rect];
}

- (void)dealloc {
    [entity release];
    [statusTint release];
    [nameLabel release];
    [statusLabel release];
    [logoView release];
    [logoFilename release];
    [progressView release];
    [super dealloc];
}

@end
