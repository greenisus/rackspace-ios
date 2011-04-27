//
//  ServerViewController.h
//  OpenStack
//
//  Created by Mike Mayo on 10/7/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import "OpenStackViewController.h"

// table view
#define kOverview -1
#define kDetails 0
#define kIPAddresses 1
#define kActions 2

#define kName 0
#define kStatus 1
#define kHostId 2

#define kImage 0
#define kMemory 1
#define kDisk 2

// actions
#define kActionsRow -1
#define kReboot -1
#define kRename 0
#define kResize 1
#define kChangePassword 2
#define kBackups 3
#define kRebuild 4
#define kDelete 5

@class Server, OpenStackAccount, ServersViewController, AnimatedProgressView, OpenStackRequest, AccountHomeViewController, NameAndStatusTitleView;

@interface ServerViewController : OpenStackViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    Server *server;
    OpenStackAccount *account;
    IBOutlet UITableView *tableView;
    NSString *selectedIPAddress;
    NSIndexPath *selectedIPAddressIndexPath;
    BOOL actionsExpanded;
    AnimatedProgressView *progressView;
    
    ServersViewController *serversViewController;
    
    UIActionSheet *ipAddressActionSheet;
    UIActionSheet *rebootActionSheet;
    UIActionSheet *deleteActionSheet;

    BOOL performingAction;
    
    id rebootSucceededObserver;
    id rebootFailedObserver;

    id getLimitsSucceededObserver;
    
    id changeAdminPasswordSucceededObserver;
    id changeAdminPasswordFailedObserver;
    
    id resizeServerSucceededObserver;
    id resizeServerFailedObserver;
    
    id deleteServerSucceededObserver;
    id deleteServerFailedObserver;
    
    id getImageSucceededObserver;
    id getImageFailedObserver;
    
    id updateBackupScheduleSucceededObserver;
    id updateBackupScheduleFailedObserver;
    
    id confirmResizeSucceededObserver;
    id confirmResizeFailedObserver;
    
    id revertResizeSucceededObserver;
    id revertResizeFailedObserver;
    
    id rebuildSucceededObserver;
    id rebuildFailedObserver;
    
    NSTimer *countdownTimer;
    NSString *rebootCountdown;
    NSString *renameCountdown;
    NSString *resizeCountdown;
    NSString *changePasswordCountdown;
    NSString *backupsCountdown;
    NSString *rebuildCountdown;
    NSString *deleteCountdown;    
    
    NSIndexPath *selectedServerIndexPath;
    
    UIImageView *actionsArrow;
    
    OpenStackRequest *pollRequest;
    BOOL polling;
    
    //NSString *previousStatus;
    
    AccountHomeViewController *accountHomeViewController;
    
    IBOutlet NameAndStatusTitleView *titleView;
    IBOutlet UIView *actionView;
    CGPoint previousScrollPoint;
    
    IBOutlet UIButton *rebootButton;
    IBOutlet UIButton *pingButton;
}

@property (retain) Server *server;
@property (retain) OpenStackAccount *account;
@property (retain) IBOutlet UITableView *tableView;
@property (retain) NSIndexPath *selectedIPAddressIndexPath;
@property (retain) ServersViewController *serversViewController;
@property (retain) NSIndexPath *selectedServerIndexPath;
@property (retain) AccountHomeViewController *accountHomeViewController;

- (void)refreshLimitStrings;

- (void)changeAdminPassword:(NSString *)password;
- (void)renameServer:(NSString *)name;
- (IBAction)rebootButtonPressed:(id)sender;
- (IBAction)snapshotButtonPressed:(id)sender;
- (IBAction)pingIPButtonPressed:(id)sender;

@end
