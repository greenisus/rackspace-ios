//
//  LoadBalancerViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerViewController.h"
#import "LoadBalancer.h"
#import <QuartzCore/QuartzCore.h>
#import "NameAndStatusTitleView.h"
#import "Server.h"

#define kDetails 0
#define kNodes 1

@implementation LoadBalancerViewController

@synthesize loadBalancer, tableViewContainer, detailsTableView, nodesTableView, titleView;

-(id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [self initWithNibName:@"LoadBalancerViewController" bundle:nil];
    if (self) {
        self.loadBalancer = lb;
        mode = kDetails;
    }
    return self;
}

- (void)dealloc {
    [loadBalancer release];
    [tableViewContainer release];
    [detailsTableView release];
    [nodesTableView release];
    [titleView release];
    [super dealloc];
}

#pragma mark - Scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint point = scrollView.contentOffset;
    CGRect tr = self.titleView.frame;
    CGRect ar = segmentView.frame;
    if (previousScrollPoint.y - point.y < 0) {
        self.titleView.frame = CGRectMake(tr.origin.x, (previousScrollPoint.y - point.y) / 3.0, tr.size.width, tr.size.height);
        segmentView.frame = CGRectMake(ar.origin.x, 64 + ((previousScrollPoint.y - point.y) / 2.0), ar.size.width, ar.size.height);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Load Balancer";
    previousScrollPoint = CGPointZero;
    self.detailsTableView.backgroundColor = [UIColor clearColor];
    
    segmentView.backgroundColor = [UIColor colorWithRed:0.929 green:0.929 blue:0.929 alpha:1];    
    segmentView.clipsToBounds = NO;
    [segmentView.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [segmentView.layer setShadowRadius:2.0f];
    [segmentView.layer setShadowOffset:CGSizeMake(1, 1)];
    [segmentView.layer setShadowOpacity:0.8f];

    if (!titleView) {    
        // make an offset for the table
        self.detailsTableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 134.0)] autorelease];
        self.nodesTableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 134.0)] autorelease];
    
        titleView = [[NameAndStatusTitleView alloc] initWithEntity:self.loadBalancer];
        [self.view addSubview:titleView];
        [titleView setNeedsDisplay];
    }    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //self.tableView.pagingEnabled
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.detailsTableView) {
        return 10;
    } else {
        return [self.loadBalancer.virtualIPs count];
    }
//    switch (mode) {
//        case kDetails:
//            return 10;
//        case kNodes:
//            return [self.loadBalancer.virtualIPs count];
//        default:
//            return 0;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    if (aTableView == self.detailsTableView) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Name";
                cell.detailTextLabel.text = self.loadBalancer.name;
                break;            
            case 1:
                cell.textLabel.text = @"Protocol";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ on Port %i", self.loadBalancer.protocol, self.loadBalancer.port];
                break;            
            case 2:
                cell.textLabel.text = @"Port";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", self.loadBalancer.port];
                break;            
            case 3:
                cell.textLabel.text = @"Cluster Name";
                cell.detailTextLabel.text = self.loadBalancer.clusterName;
                break;
            case 4:
                cell.textLabel.text = @"Status";
                cell.detailTextLabel.text = self.loadBalancer.status;
                break;            
            case 5:
                cell.textLabel.text = @"Session Persistence";
                cell.detailTextLabel.text = self.loadBalancer.sessionPersistenceType;
                break;            
            case 6:
                cell.textLabel.text = @"Virtual IPs";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.loadBalancer.virtualIPs count]];
                break;
            case 7:
                cell.textLabel.text = @"Algorithm";
                cell.detailTextLabel.text = self.loadBalancer.algorithm;
                break;
            case 8:
                cell.textLabel.text = @"Nodes";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [self.loadBalancer.nodes count]];
                break;
            default:
                break;
        }
    } else {
        cell.textLabel.text = @"Virtual IP";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
}

#pragma mark - Segmented Control

- (IBAction)segmentedControlChanged:(UISegmentedControl *)segmentedControl {
    [UIView animateWithDuration:0.35 animations:^{
        CGRect r = self.tableViewContainer.frame;
        if (segmentedControl.selectedSegmentIndex == kNodes) {
            r.origin.x -= 320;
        } else {
            r.origin.x += 320;
        }
        self.tableViewContainer.frame = r;
    }];
     
    /*
    NSInteger previousMode = mode;
    mode = segmentedControl.selectedSegmentIndex;
    
    NSInteger previousNumberOfRows = 10;
    NSInteger newNumberOfRows = 1;
    
    NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i = newNumberOfRows; i < previousNumberOfRows; i++) {
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 0; i < newNumberOfRows; i++) {
        [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
    [deleteIndexPaths release];
     [insertIndexPaths release];
     */
}

@end
