//
//  AddLoadBalancerAlgorithmViewController.m
//  OpenStack
//
//  Created by Michael Mayo on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLoadBalancerAlgorithmViewController.h"
#import "OpenStackAccount.h"
#import "UIViewController+Conveniences.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadBalancer.h"

#define kRandom 0
#define kRoundRobin 1
#define kWeightedRoundRobin 2
#define kLeastConnections 3
#define kWeightedLeastConnections 4

#define kNodes 5
#define kAnimationTime 0.5


@implementation AddLoadBalancerAlgorithmViewController

@synthesize account, loadBalancer, tableView, pickerView;

- (id)initWithAccount:(OpenStackAccount *)a {
    self = [super initWithNibName:@"AddLoadBalancerAlgorithmViewController" bundle:nil];
    if (self) {
        self.account = a;
    }
    return self;
}

- (void)dealloc {
    [account release];
    [loadBalancer release];
    [tableView release];
    [pickerView release];
    [loadBalancerIcon release];
    [serverIcons release];
    [dots release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Algorithm";
    [self addNextButton];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch ([self.pickerView selectedRowInComponent:0]) {
        case kRandom:
            return @"Directs traffic to a randomly selected node.";
        case kRoundRobin:
            return @"Directs traffic in a circular pattern to each node of a load balancer in succession.";
        case kWeightedRoundRobin:
            return @"Directs traffic in a circular pattern to each node of a load balancer in succession with a larger proportion of requests being serviced by nodes with a greater weight.";
        case kLeastConnections:
            return @"Directs traffic to the node with the fewest open connections to the load balancer.";
        case kWeightedLeastConnections:
            return @"Directs traffic to the node with the fewest open connections between the load balancer.  Nodes with a larger weight will service more connections at any one time.";
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 132;
}

- (void)animateDot:(NSInteger)dotIndex toServer:(NSInteger)serverIndex {
    UIView *dot = [dots objectAtIndex:dotIndex];
    dot.frame = CGRectMake(10, 30, 6, 6);
    dot.alpha = 0;
    [dot setNeedsDisplay];

    [UIView animateWithDuration:kAnimationTime delay:dotIndex * kAnimationTime options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect goal = dot.frame;
        goal.origin.x += 140;
        dot.frame = goal;
        dot.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationTime delay:0 options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            
            if ([self.pickerView selectedRowInComponent:0] == kRandom) {                
                dot.center = [[serverIcons objectAtIndex:arc4random() % kNodes] center];
            } else if ([self.pickerView selectedRowInComponent:0] == kRoundRobin || [self.pickerView selectedRowInComponent:0] == kWeightedRoundRobin) {
                dot.center = [[serverIcons objectAtIndex:serverIndex] center];
            } else if ([self.pickerView selectedRowInComponent:0] == kLeastConnections || [self.pickerView selectedRowInComponent:0] == kWeightedLeastConnections) {
                if (dotIndex < kNodes - 2) {
                    dot.center = [[serverIcons objectAtIndex:0] center];
                } else {
                    dot.center = [[serverIcons objectAtIndex:1] center];
                }
            }
            
        } completion:^(BOOL finished) {
            if (dotIndex == kNodes - 1) {
                [self animateDots];
            }
        }];
    }];
}

- (void)animateDot:(NSTimer *)timer {
    [self animateDot:[[timer.userInfo objectForKey:@"dotIndex"] intValue] toServer:[[timer.userInfo objectForKey:@"serverIndex"] intValue]];
}

- (void)animateDots {
    for (int i = 0; i < kNodes; i++) {
        [self animateDot:i toServer:i];
    }
}

- (UITableViewCell *)algorithmCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        loadBalancerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"load-balancers-icon.png"]];
        loadBalancerIcon.center = cell.center;
        CGRect r = loadBalancerIcon.frame;
        r.origin.y += 10;
        loadBalancerIcon.frame = r;
//        loadBalancerIcon.clipsToBounds = NO;
//        [loadBalancerIcon.layer setShadowColor:[[UIColor blackColor] CGColor]];
//        [loadBalancerIcon.layer setShadowRadius:1.0f];
//        [loadBalancerIcon.layer setShadowOffset:CGSizeMake(1, 1)];
//        [loadBalancerIcon.layer setShadowOpacity:0.8f];
        
        [cell addSubview:loadBalancerIcon];
        
        serverIcons = [[NSMutableArray alloc] initWithCapacity:5];
        dots = [[NSMutableArray alloc] initWithCapacity:5];
        
        for (int i = 0; i < kNodes; i++) {
            UIImageView *server = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-icon.png"]];
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 6, 6)];
            dot.backgroundColor = [UIColor redColor];
            dot.layer.cornerRadius = 3.5;
            server.frame = CGRectMake(20 + (61 * i), 80, 35, 35);
//            server.clipsToBounds = NO;
//            [server.layer setShadowColor:[[UIColor blackColor] CGColor]];
//            [server.layer setShadowRadius:1.0f];
//            [server.layer setShadowOffset:CGSizeMake(1, 1)];
//            [server.layer setShadowOpacity:0.8f];
            [cell addSubview:server];
            [cell addSubview:dot];
            [cell sendSubviewToBack:dot];
            [serverIcons addObject:server];
            [dots addObject:dot];
            [server release];
            [dot release];
        }
        
        //[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(animateDots) userInfo:nil repeats:NO];
        [self animateDots];
        
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self algorithmCell:self.tableView];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
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
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - Picker data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

#pragma mark - Picker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case kRandom:
            return @"Random";
        case kRoundRobin:
            return @"Round Robin";
        case kWeightedRoundRobin:
            return @"Weighted Round Robin";
        case kLeastConnections:
            return @"Least Connections";
        case kWeightedLeastConnections:
            return @"Weighted Least Connections";
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // change the animation
    [self.tableView reloadData];
    //[self animateDots];
}

@end
