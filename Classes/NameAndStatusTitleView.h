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

@property (nonatomic, retain) id entity;
@property (nonatomic, retain) UIView *statusTint;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *logoView;
@property (nonatomic, retain) NSString *logoFilename;
@property (nonatomic, retain) DDProgressView *progressView;

- (id)initWithEntity:(id)entity;
- (id)initWithEntity:(id)entity logoFilename:(NSString *)filename;

@end
