//
//  LBAlgorithmViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LBAlgorithmViewController.h"
#import "LoadBalancer.h"
#import "UIViewController+Conveniences.h"

#define kRandom 0
#define kRoundRobin 1
#define kWeightedRoundRobin 2
#define kLeastConnections 3
#define kWeightedLeastConnections 4

@implementation LBAlgorithmViewController

@synthesize loadBalancer;

- (id)initWithLoadBalancer:(LoadBalancer *)lb {
    self = [super initWithNibName:@"LBAlgorithmViewController" bundle:nil];
    if (self) {
        self.loadBalancer = lb;
    }
    return self;
}

- (void)dealloc {
    [loadBalancer release];
    [descriptions release];
    [algorithmValues release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Algorithm";
    self.tableView.backgroundColor = [UIColor whiteColor];
    descriptions = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"Directs traffic to a randomly selected node.", @"Random",
                        @"Directs traffic in a circular pattern to each node of a load balancer in succession.", @"Round Robin",
                        @"Directs traffic in a circular pattern to each node of a load balancer in succession with a larger proportion of requests being serviced by nodes with a greater weight.", @"Weighted Round Robin",
                        @"Directs traffic to the node with the fewest open connections to the load balancer.", @"Least Connections",
                        @"Directs traffic to the node with the fewest open connections between the load balancer.  Nodes with a larger weight will service more connections at any one time.", @"Weighted Least Connections",
                        nil];
    
    algorithmValues = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"RANDOM", @"Random",
                       @"ROUND_ROBIN", @"Round Robin",
                       @"WEIGHTED_ROUND_ROBIN", @"Weighted Round Robin",
                       @"LEAST_CONNECTIONS", @"Least Connections",
                       @"WEIGHTED_LEAST_CONNECTIONS", @"Weighted Least Connections",
                       nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return tableView.rowHeight;
    } else {
        NSString *description = @"";
        if (indexPath.section == kRandom) {
            description = [descriptions objectForKey:@"Random"];
        } else if (indexPath.section == kRoundRobin) {
            description = [descriptions objectForKey:@"Round Robin"];
        } else if (indexPath.section == kWeightedRoundRobin) {
            description = [descriptions objectForKey:@"Weighted Round Robin"];
        } else if (indexPath.section == kLeastConnections) {
            description = [descriptions objectForKey:@"Least Connections"];
        } else if (indexPath.section == kWeightedLeastConnections) {
            description = [descriptions objectForKey:@"Weighted Least Connections"];
        }
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [description sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width - 40, 25000) lineBreakMode:UILineBreakModeWordWrap];
        return 30 + size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView titleCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TitleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey-highlight.png"]] autorelease];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"purple-highlight.png"]] autorelease];
    
    switch (indexPath.section) {
        case kRandom:
            cell.textLabel.text = @"Random";
            break;
        case kRoundRobin:
            cell.textLabel.text = @"Round Robin";
            break;
        case kWeightedRoundRobin:
            cell.textLabel.text = @"Weighted Round Robin";
            break;
        case kLeastConnections:
            cell.textLabel.text = @"Least Connections";
            break;
        case kWeightedLeastConnections:
            cell.textLabel.text = @"Weighted Least Connections";
            break;
        default:
            break;
    }
    
    cell.detailTextLabel.text = @"";
    
    if ([self.loadBalancer.algorithm isEqualToString:[algorithmValues objectForKey:cell.textLabel.text]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView descriptionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DescriptionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 22, 22);
        [button setImage:[UIImage imageNamed:@"purple-camera.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
         
    }
    
    cell.textLabel.text = @"";
//    cell.imageView.image = [UIImage imageNamed:@"purple-camera.png"];
    
    switch (indexPath.section) {
        case kRandom:
            cell.detailTextLabel.text = [descriptions objectForKey:@"Random"];
            break;
        case kRoundRobin:
            cell.detailTextLabel.text = [descriptions objectForKey:@"Round Robin"];
            break;
        case kWeightedRoundRobin:
            cell.detailTextLabel.text = [descriptions objectForKey:@"Weighted Round Robin"];
            break;
        case kLeastConnections:
            cell.detailTextLabel.text = [descriptions objectForKey:@"Least Connections"];
            break;
        case kWeightedLeastConnections:
            cell.detailTextLabel.text = [descriptions objectForKey:@"Weighted Least Connections"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [self tableView:tableView titleCellForRowAtIndexPath:indexPath];
    } else {
        return [self tableView:tableView descriptionCellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kRandom:
            self.loadBalancer.algorithm = @"RANDOM";
            break;
        case kRoundRobin:
            self.loadBalancer.algorithm = @"ROUND_ROBIN";
            break;
        case kWeightedRoundRobin:
            self.loadBalancer.algorithm = @"WEIGHTED_ROUND_ROBIN";
            break;
        case kLeastConnections:
            self.loadBalancer.algorithm = @"LEAST_CONNECTIONS";
            break;
        case kWeightedLeastConnections:
            self.loadBalancer.algorithm = @"WEIGHTED_LEAST_CONNECTIONS";
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Button Handlers

- (void)cameraButtonPressed:(id)sender {
    [self alert:@"Algorithm Video" message:@"Not yet implemented."];
}

@end
