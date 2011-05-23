//
//  MediaViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 1/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>


@class Container, StorageObject;

@interface MediaViewController : UIViewController {
    Container *container;
    StorageObject *object;
    MPMoviePlayerController *player;
    id observer;
}

@property (nonatomic, retain) Container *container;
@property (nonatomic, retain) StorageObject *object;

@end
