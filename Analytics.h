//
//  Constants.h
//  OpenStack
//
//  Created by Matthew Newberry on 05/18/11.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "GANTracker.h"

// Analytics Keys
#define CATEGORY_SERVER @"server"
#define CATEGORY_CONTAINERS @"containers"
#define CATEGORY_FILES @"files"
#define CATEGORY_LOAD_BALANCER @"load_balancer"

#define EVENT_REBOOTED @"reboot"
#define EVENT_CREATED @"created"
#define EVENT_UPDATED @"updated"
#define EVENT_PINGED @"pinged"
#define EVENT_RESIZED @"resized"
#define EVENT_REBUILT @"rebuilt"
#define EVENT_DELETED @"deleted"
#define EVENT_BACKUP_SCHEDULE_CHANGED @"backup_schedule_changed"
#define EVENT_RENAMED @"renamed"
#define EVENT_PASSWORD_CHANGED @"password_changed"

void TrackEvent(NSString *category, NSString *action);
void TrackViewController(UIViewController *vc);
void DispatchAnalytics();