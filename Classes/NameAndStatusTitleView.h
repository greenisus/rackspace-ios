//
//  NameAndStatusTitleView.h
//  OpenStack
//
//  Created by Michael Mayo on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Server, DDProgressView;

@interface NameAndStatusTitleView : UIView {
    
    // The entity for this view should respond to the following selectors:
    // name, status, progress, shouldBePolled
    id entity;
    
    UIView *statusTint;
    UILabel *nameLabel;
    UILabel *statusLabel;
    UIImageView *logoView;
    NSString *logoFilename;
    DDProgressView *progressView;
}

@property (retain) id entity;
@property (retain) UIView *statusTint;
@property (retain) UILabel *nameLabel;
@property (retain) UILabel *statusLabel;
@property (retain) UIImageView *logoView;
@property (retain) NSString *logoFilename;
@property (retain) DDProgressView *progressView;

- (id)initWithEntity:(id)entity;
- (id)initWithEntity:(id)entity logoFilename:(NSString *)filename;

@end
