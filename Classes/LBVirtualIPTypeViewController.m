//
//  LBVirtualIPTypeViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBVirtualIPTypeViewController.h"
#import "OpenStackAccount.h"
#import "LoadBalancer.h"
#import "AccountManager.h"
#import "UIViewController+Conveniences.h"

#define kPublic 0
#define kServiceNet 1
#define kSharedVirtualIP 2

@implementation LBVirtualIPTypeViewController

@synthesize account, loadBalancer;

- (id)initWithAccount:(OpenStackAccount *)a loadBalancer:(LoadBalancer *)lb {
    self = [self initWithNibName:@"LBVirtualIPTypeViewController" bundle:nil];
    if (self) {
        self.account = a;
        self.loadBalancer = lb;
        descriptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"This Load Balancer is accessible over the Internet.", @"Public", 
                        @"This Load Balancer can only be reached from within the data center. Inbound and outbound bandwidth fees don’t apply.", @"ServiceNet", 
                        @"Share a common address between multiple load balancers. Useful to balance HTTP and HTTPS on a common IP for DNS. Unique ports must be used for each load balancer behind the IP.", @"Shared Virtual IP",
                        nil];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [account release];
    [loadBalancer release];
    [descriptions release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Virtual IP Type";
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight;
    } else {
        NSString *description = @"";
        if (indexPath.section == kPublic) {
            description = [descriptions objectForKey:@"Public"];
        } else if (indexPath.section == kServiceNet) {
            description = [descriptions objectForKey:@"ServiceNet"];
        } else if (indexPath.section == kSharedVirtualIP) {
            description = [descriptions objectForKey:@"Shared Virtual IP"];
        }
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [description sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40, 25000) lineBreakMode:UILineBreakModeWordWrap];
        return 30 + size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey-highlight.png"]] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purple-highlight.png"]] autorelease];
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == kPublic) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Public";
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [descriptions objectForKey:@"Public"];
        }
    } else if (indexPath.section == kServiceNet) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"ServiceNet";
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [descriptions objectForKey:@"ServiceNet"];
        }
    } else if (indexPath.section == kSharedVirtualIP) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Shared Virtual IP";
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [descriptions objectForKey:@"Shared Virtual IP"];
        }
    }
    
    if ([self.loadBalancer.virtualIPType isEqualToString:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)selectRow:(NSTimer *)timer {
    [self.tableView selectRowAtIndexPath:[timer.userInfo objectForKey:@"indexPath"] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPublic) {
        self.loadBalancer.virtualIPType = @"Public";
    } else if (indexPath.section == kServiceNet) {
        self.loadBalancer.virtualIPType = @"ServiceNet";
    } else if (indexPath.section == kSharedVirtualIP) {
        self.loadBalancer.virtualIPType = @"Shared Virtual IP";
    }    

    [self.navigationController popViewControllerAnimated:YES];
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] forKey:@"indexPath"];
//    [NSTimer scheduledTimerWithTimeInterval:0.10 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(selectRow:) userInfo:userInfo repeats:NO];
    
}

@end
