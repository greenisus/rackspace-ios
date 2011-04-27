//
//  RSSFeedViewController.m
//  OpenStack
//
//  Created by Mike Mayo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSSFeedViewController.h"
#import "ASIHTTPRequest.h"
#import "ActivityIndicatorView.h"
#import "UIViewController+Conveniences.h"
#import "RSSParser.h"
#import "UIColor+MoreColors.h"
#import "FeedItem.h"
#import "NSObject+Conveniences.h"


@implementation RSSFeedViewController

@synthesize feed, feedItems;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark View lifecycle

- (void)orientationDidChange:(NSNotification *)notification {
	// reload the table view to correct UILabel widths
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"RSS Feed";
    self.tableView.allowsSelection = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.backgroundColor = [UIColor iPadTableBackgroundColor];
        self.tableView.separatorColor = [UIColor iPadTableBackgroundColor];
    }    
    
	// register for rotation events to keep the rss feed width correct
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(orientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [feed objectForKey:@"name"];
    
    NSString *activityMessage = @"Loading...";
    activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:[ActivityIndicatorView frameForText:activityMessage] text:activityMessage];
    [activityIndicatorView addToView:self.view scrollOffset:self.tableView.contentOffset.y];    
    
    NSURL *url = [NSURL URLWithString:[feed objectForKey:@"url"]];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request setCompletionBlock:^{
        if ((200 <= [request responseStatusCode]) && ([request responseStatusCode] <= 299)) {
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
            RSSParser *rssParser = [[RSSParser alloc] init];
            xmlParser.delegate = rssParser;
            if ([xmlParser parse]) {
                [self.feedItems release];
                self.feedItems = rssParser.feedItems;
            }            
            [rssParser release];
            [xmlParser release];
            self.tableView.separatorColor = [UIColor lightGrayColor];
        } else {
            requestFailed = YES;
            self.tableView.scrollEnabled = NO;
        }        
        [activityIndicatorView removeFromSuperviewAndRelease];
        [self.tableView reloadData];
    }];
    [request setFailedBlock:^{
        requestFailed = YES;
        self.tableView.scrollEnabled = NO;
        [activityIndicatorView removeFromSuperviewAndRelease];
        [self.tableView reloadData];
    }];    
    [request startAsynchronous];
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (requestFailed) {
        return 1;
    } else if (self.feedItems) {
        return [self.feedItems count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (requestFailed) {
        return tableView.frame.size.height;
    } else {
        if ([self.feedItems count] > 0) {
            FeedItem *item = [self.feedItems objectAtIndex:indexPath.row];
            CGSize titleSize = [item.title sizeWithFont:[UIFont systemFontOfSize:17.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGSize contentSize = [item.content sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGSize dateSize = [[RSSFeedViewController dateToStringWithTime:item.pubDate] sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGSize authorSize = [[NSString stringWithFormat:@"Posted by %@", item.creator] sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];            
            return 41.0 + titleSize.height + contentSize.height + dateSize.height + authorSize.height;
        } else {
            return tableView.rowHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (requestFailed) {
        return [self tableView:tableView emptyCellWithImage:[UIImage imageNamed:@"empty-rss.png"] title:@"Feed Unavailable" subtitle:@"Please check your connection and try again."];
    } else {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            
            FeedItem *item = [self.feedItems objectAtIndex:indexPath.row];            
            
            UIFont *titleFont = [UIFont boldSystemFontOfSize:17.0];
            UIFont *dateFont = [UIFont systemFontOfSize:15.0];
            UIFont *contentFont = [UIFont systemFontOfSize:15.0];
            UIFont *authorFont = [UIFont systemFontOfSize:13.0];
            
            CGSize titleSize = [item.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGRect titleRect = CGRectMake(10.0, 13.0, titleSize.width, titleSize.height);

            UILabel *title = [[[UILabel alloc] initWithFrame:titleRect] autorelease];
            title.font = titleFont;
            title.textColor = [UIColor colorWithRed:0.302 green:0.388 blue:0.663 alpha:1.0];            
            title.backgroundColor = [UIColor clearColor];
            title.numberOfLines = 0;
            title.lineBreakMode = UILineBreakModeWordWrap;
            title.text = item.title;
            title.tag = 55;
            [cell addSubview:title];

            CGSize dateSize = [[RSSFeedViewController dateToStringWithTime:item.pubDate] sizeWithFont:dateFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGRect dateRect = CGRectMake(10.0, 13.0 + titleRect.size.height, dateSize.width, dateSize.height);            
            UILabel *date = [[[UILabel alloc] initWithFrame:dateRect] autorelease];
            date.font = dateFont;
            date.textColor = [UIColor grayColor];
            date.backgroundColor = [UIColor clearColor];
            date.numberOfLines = 0;
            date.lineBreakMode = UILineBreakModeWordWrap;
            date.text = [RSSFeedViewController dateToStringWithTime:item.pubDate];
            date.tag = 56;
            [cell addSubview:date];
            
            CGSize authorSize = [[NSString stringWithFormat:@"Posted by %@", item.creator] sizeWithFont:authorFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGRect authorRect = CGRectMake(10.0, 14.0 + dateSize.height + titleRect.size.height, authorSize.width, authorSize.height);
            UILabel *author = [[[UILabel alloc] initWithFrame:authorRect] autorelease];
            author.font = authorFont;
            author.textColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.208 alpha:1.0];
            author.backgroundColor = [UIColor clearColor];
            author.numberOfLines = 0;
            author.lineBreakMode = UILineBreakModeWordWrap;
            author.text = [NSString stringWithFormat:@"Posted by %@", item.creator];
            author.tag = 57;
            [cell addSubview:author];
            
            CGSize contentSize = [item.content sizeWithFont:contentFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            CGRect contentRect = CGRectMake(10.0, 27.0 + dateSize.height + authorSize.height + titleRect.size.height, contentSize.width, contentSize.height);
            UILabel *content = [[[UILabel alloc] initWithFrame:contentRect] autorelease];
            content.font = contentFont;
            content.textColor = [UIColor blackColor];
            content.backgroundColor = [UIColor clearColor];
            content.numberOfLines = 0;
            content.lineBreakMode = UILineBreakModeWordWrap;
            content.text = item.content;
            content.tag = 58;
            [cell addSubview:content];            
        }
        
        FeedItem *item = [self.feedItems objectAtIndex:indexPath.row];
                
        UIFont *titleFont = [UIFont boldSystemFontOfSize:17.0];        
        UIFont *dateFont = [UIFont systemFontOfSize:15.0];
        UIFont *contentFont = [UIFont systemFontOfSize:15.0];
        UIFont *authorFont = [UIFont systemFontOfSize:13.0];
        
        // Title
        CGSize titleSize = [item.title sizeWithFont:titleFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect titleRect = CGRectMake(10.0, 13.0, titleSize.width, titleSize.height);        
        UILabel *title = (UILabel *)[cell viewWithTag:55];
        title.frame = titleRect;
        title.text = item.title;

        // Date
        CGSize dateSize = [[RSSFeedViewController dateToStringWithTime:item.pubDate] sizeWithFont:dateFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect dateRect = CGRectMake(10.0, 13.0 + titleRect.size.height, dateSize.width, dateSize.height);            
        UILabel *date = (UILabel *)[cell viewWithTag:56];
        date.frame = dateRect;
        date.text = [RSSFeedViewController dateToStringWithTime:item.pubDate];
        
        // Author
        CGSize authorSize = [[NSString stringWithFormat:@"Posted by %@", item.creator] sizeWithFont:authorFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect authorRect = CGRectMake(10.0, 14.0 + dateSize.height + titleRect.size.height, authorSize.width, authorSize.height);
        UILabel *author = (UILabel *)[cell viewWithTag:57];
        author.frame = authorRect;
        author.text = [NSString stringWithFormat:@"Posted by %@", item.creator];
        
        // Content
        CGSize contentSize = [item.content sizeWithFont:contentFont constrainedToSize:CGSizeMake(tableView.frame.size.width - 20.0, tableView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
        CGRect contentRect = CGRectMake(10.0, 27.0 + dateSize.height + authorSize.height + titleRect.size.height, contentSize.width, contentSize.height);
        UILabel *content = (UILabel *)[cell viewWithTag:58];
        content.frame = contentRect;
        content.text = item.content;
        
        return cell;
    }    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [feed release];
    [feedItems release];
    [super dealloc];
}

@end

