//
//  NewsViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import "NewsViewController.h"
#import "DetailViewController.h"
#import "News.h"
#import "NewsReaderAppDelegate.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>


static NSUInteger const kTitleLabelTag = 22;
static NSUInteger const kDescLabelTag = 23;
static NSUInteger const kImageViewTag = 24;
static NSUInteger const kGuidesTitleLabelTag = 25;
static NSUInteger const kGuidesItemLabelTagBase = 26;

@implementation NewsViewController

@synthesize loadingView, activityInicatorView;
@synthesize newspaper, headlines, guides, haveHeadlines, imageDownloadsInProgress;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT)];
        [self.loadingView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.loadingView];
        
        self.activityInicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self.activityInicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingView addSubview:self.activityInicatorView];
    }
    return self;
}

- (void)dealloc
{
    [loadingView release];
    [activityInicatorView release];
    [newspaper release];
    [headlines release];
    [guides release];
    [imageDownloadsInProgress release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"News List", @"The title of the news list view.");
    
    // KVO: listen for changes to our news data source for table view updates
    [self addObserver:self forKeyPath:@"newsList" options:0 context:NULL];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.newspaper = nil;

    [self removeObserver:self forKeyPath:@"newsList"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.loadingView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
    } else {
        self.loadingView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - 20);
    }

    [self.activityInicatorView setCenter:self.loadingView.center];

    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIInterfaceOrientation toOrientation = self.interfaceOrientation;
        
        // Set cell layout of the guides cell.
        if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
            UILabel *guidesTitleLabel = (UILabel *)[cell.contentView viewWithTag:kGuidesTitleLabelTag];
            [guidesTitleLabel setFrame:CGRectMake(10, 10, 50, 20)];
            NSUInteger index = 0;
            while (index < [self.guides count]) {
                UILabel *guidesItemLabel = (UILabel *)[cell.contentView viewWithTag:(kGuidesItemLabelTagBase + index)];
                if (toOrientation == UIInterfaceOrientationPortrait ||
                    toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                    guidesItemLabel.frame = CGRectMake(65, 10 + 25 * index, APP_WIDTH - 85, 20);
                } else {
                    guidesItemLabel.frame = CGRectMake(65, 10 + 25 * index, APP_HEIGHT - 85, 20);
                }
                index++;
            }
        } else {
            // Set cell layouts of the headlines and the normal cells.
            UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
            UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
            
            UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
            if (self.haveHeadlines && indexPath.section == 0) {
                if (toOrientation == UIInterfaceOrientationPortrait ||
                    toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                    CGFloat descHeight = [descLabel.text sizeWithFont:font
                                                    constrainedToSize:CGSizeMake(APP_WIDTH - 20, CGFLOAT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap].height;
                    CGFloat descYPos = HEAD_NEWS_IMG_HEIGHT + 35;
                    if (imageView.hidden) {
                        descYPos = 30;
                    }
                    titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - 20, 20);
                    descLabel.frame = CGRectMake(10, descYPos, APP_WIDTH - 20, descHeight);
                    imageView.frame = CGRectMake((APP_WIDTH - HEAD_NEWS_IMG_WIDTH) / 2, 30,
                                                 HEAD_NEWS_IMG_WIDTH, HEAD_NEWS_IMG_HEIGHT);
                } else {
                    CGFloat descHeight = [descLabel.text sizeWithFont:font
                                                    constrainedToSize:CGSizeMake(APP_HEIGHT - 20, CGFLOAT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap].height;
                    CGFloat descYPos = HEAD_NEWS_IMG_HEIGHT + 35;
                    if (imageView.hidden) {
                        descYPos = 30;
                    }
                    titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - 20, 20);
                    descLabel.frame = CGRectMake(10, descYPos, APP_HEIGHT - 20, descHeight);
                    imageView.frame = CGRectMake((APP_HEIGHT - HEAD_NEWS_IMG_WIDTH) / 2, 30,
                                                 HEAD_NEWS_IMG_WIDTH, HEAD_NEWS_IMG_HEIGHT);
                }
            } else {
                if (toOrientation == UIInterfaceOrientationPortrait ||
                    toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                    CGFloat descWidth = APP_WIDTH - NEWS_IMG_WIDTH - 25;
                    if (imageView.hidden) {
                        descWidth = APP_WIDTH - 20;
                    }
                    CGFloat descHeight = [descLabel.text sizeWithFont:font
                                                    constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap].height;
                    titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - 20, 20);
                    descLabel.frame = CGRectMake(10, 30, descWidth, descHeight);
                    imageView.frame = CGRectMake(APP_WIDTH - NEWS_IMG_WIDTH - 10, 30, NEWS_IMG_WIDTH, NEWS_IMG_HEIGHT);
                } else {
                    CGFloat descWidth = APP_HEIGHT - NEWS_IMG_WIDTH - 25;
                    if (imageView.hidden) {
                        descWidth = APP_HEIGHT - 20;
                    }
                    CGFloat descHeight = [descLabel.text sizeWithFont:font
                                                    constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap].height;
                    titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - 20, 20);
                    descLabel.frame = CGRectMake(10, 30, descWidth, descHeight);
                    imageView.frame = CGRectMake(APP_HEIGHT - NEWS_IMG_WIDTH - 10, 30, NEWS_IMG_WIDTH, NEWS_IMG_HEIGHT);
                }
            }
            
            // Set shadow for image view.
            imageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake(2, 2);
            imageView.layer.shadowOpacity = 0.8;
            imageView.layer.shadowRadius = 3.0;
            imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
        }
    }
}

#pragma mark -
#pragma mark KVO support

- (void)insertNews:(NSArray *)newsArray
{
    // this will allow us as an observer to notified (see observeValueForKeyPath)
    // so we can update our UITableView
    //
    [self willChangeValueForKey:@"newsList"];
    
    [self.guides removeAllObjects];
    self.guides = [NSMutableDictionary dictionary];
    [self.imageDownloadsInProgress removeAllObjects];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    NSPredicate *predicate;

    predicate = [NSPredicate predicateWithFormat:@"type = 'headline'"];
    self.headlines = [newsArray filteredArrayUsingPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"type != 'headline'"];
    NSArray *normal = [newsArray filteredArrayUsingPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *channelDescriptor = [[NSSortDescriptor alloc] initWithKey:@"channel" ascending:YES];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:channelDescriptor, dateDescriptor, nil];
    NSArray *sortedArray = [normal sortedArrayUsingDescriptors:sortDescriptors];
    [channelDescriptor release];
    [dateDescriptor release];
    [sortDescriptors release];
    
    NSInteger index = 0;
    NSInteger section = 0;
    NSArray *subArray;
    while (index < [sortedArray count]) {
        predicate = [NSPredicate predicateWithFormat:
                     @"channel = %@", ((NewsObject *)[sortedArray objectAtIndex:index]).channel];
        subArray = [sortedArray filteredArrayUsingPredicate:predicate];
        [self.newspaper addObject:subArray];
        NSInteger row = 0;
        while (row < [subArray count]) {
            NewsObject *news = [subArray objectAtIndex:row];
            if ([news.type isEqualToString:@"guide"]) {
                [self.guides setObject:news.title forKey:[NSIndexPath indexPathForRow:row inSection:section]];
            }
            row++;
        }
        index += row;
        section++;
    }
    
    if ([self.headlines count] > 0 || [self.guides count] > 0) {
        self.haveHeadlines = YES;
    } else {
        self.haveHeadlines = NO;
    }

    [self didChangeValueForKey:@"newsList"];
}

// listen for changes to the news list coming from our rootViewController.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context
{
    [self.tableView reloadData];
    
    [self.activityInicatorView stopAnimating];
    self.loadingView.hidden = YES;
}

- (NSIndexPath *)cellIndexPathFromArrayIndexPath:(NSIndexPath *)indexPath
{
    if (self.haveHeadlines) {
        return [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section + 1)];
    } else {
        return indexPath;
    }
}

- (NSIndexPath *)arrayIndexPathFromCellIndexPath:(NSIndexPath *)indexPath
{
    if (self.haveHeadlines) {
        return [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)];
    } else {
        return indexPath;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.newspaper count] == 0) {
        return 1;
    }
    if (self.haveHeadlines) {
        return [self.newspaper count] + 1;
    } else {
        return [self.newspaper count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.newspaper count] == 0) {
        return 1;
    }
    if (self.haveHeadlines) {
        if (section == 0) {
            return [self.headlines count] + 1;
        } else {
            return [[self.newspaper objectAtIndex:(section - 1)] count];
        }
    } else {
        return [[self.newspaper objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    static NSString *GuidesCellIdentifier = @"GuidesCell";
    static NSString *LoadingCellIdentifier = @"LoadingCell";

    // Initialize the table cell for no content.
    if ([self.newspaper count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:LoadingCellIdentifier] autorelease];   
        }
		return cell;
    }
    
    // Create cell for guides at the last row of the first section.
    if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
        UILabel *guidesTitleLabel = nil;

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GuidesCellIdentifier];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:GuidesCellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        guidesTitleLabel = [[[UILabel alloc] init] autorelease];
        guidesTitleLabel.tag = kGuidesTitleLabelTag;
        guidesTitleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FSIZE];
        guidesTitleLabel.text = NSLocalizedString(@"Guides", @"The title of the guides cell.");
        [cell.contentView addSubview:guidesTitleLabel];
        
        NSUInteger index = 0;
        for (NSIndexPath *arrayIndexPath in self.guides) {
            TouchedLabel *guidesItemLabel = [[[TouchedLabel alloc] init] autorelease];
            guidesItemLabel.tag = kGuidesItemLabelTagBase + index;
            guidesItemLabel.font = [UIFont systemFontOfSize:TITLE_FSIZE];
            guidesItemLabel.text = [self.guides objectForKey:arrayIndexPath];
            guidesItemLabel.textColor = [UIColor blueColor];
            guidesItemLabel.userInteractionEnabled = YES;
            guidesItemLabel.indexPath = [self cellIndexPathFromArrayIndexPath:arrayIndexPath];
            guidesItemLabel.delegate = self;
            [cell.contentView addSubview:guidesItemLabel];
            index++;
        }
        
        return cell;
    }
    
    // Initialize the table cells for headlines and normal news.
    UILabel *titleLabel = nil;
    UILabel *descLabel = nil;
    UIImageView *imageView = nil;

    NewsObject *news;
    if (self.haveHeadlines && indexPath.section == 0) {
        news = (NewsObject *)[self.headlines objectAtIndex:indexPath.row];
    } else {
        NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:indexPath];
        news = (NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section] objectAtIndex:arrayIndexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        
        titleLabel = [[[UILabel alloc] init] autorelease];
        titleLabel.tag = kTitleLabelTag;
        titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FSIZE];
        [cell.contentView addSubview:titleLabel];
        
        descLabel = [[[UILabel alloc] init] autorelease];
        descLabel.tag = kDescLabelTag;
        descLabel.font = [UIFont systemFontOfSize:DESC_FSIZE];
        descLabel.lineBreakMode = UILineBreakModeWordWrap;
        descLabel.numberOfLines = 0;
        [cell.contentView addSubview:descLabel];
        
        imageView = [[[UIImageView alloc] init] autorelease];
        imageView.tag = kImageViewTag;
        [cell.contentView addSubview:imageView];
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews using their tags.
        titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
        descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
        imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
    }
    
    titleLabel.text = news.title;
    descLabel.text = news.desc;
    
    // Download news image if the news have one.
    if (news.imgurl) {
        imageView.hidden = NO;
        
        // Only load cached images; defer new downloads until scrolling ends
        ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
        if (imageDownloader == nil || imageDownloader.image == nil) {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
                [self startImageDownload:news.imgurl forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            imageView.image = [UIImage imageNamed:@"Placeholder.png"];                
        }
        else {
            imageView.image = imageDownloader.image;
        }
    } else {
        imageView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.newspaper count] == 0) {
        return;
    }
    
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;

    // Set cell layout of the guides cell.
    if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
        UILabel *guidesTitleLabel = (UILabel *)[cell.contentView viewWithTag:kGuidesTitleLabelTag];
        [guidesTitleLabel setFrame:CGRectMake(10, 10, 50, 20)];
        NSUInteger index = 0;
        while (index < [self.guides count]) {
            UILabel *guidesItemLabel = (UILabel *)[cell.contentView viewWithTag:(kGuidesItemLabelTagBase + index)];
            if (toOrientation == UIInterfaceOrientationPortrait ||
                toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                guidesItemLabel.frame = CGRectMake(65, 10 + 25 * index, APP_WIDTH - 85, 20);
            } else {
                guidesItemLabel.frame = CGRectMake(65, 10 + 25 * index, APP_HEIGHT - 85, 20);
            }
            index++;
        }
        return;
    }
    
    // Set cell layouts of the headlines and the normal cells.
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
    UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
    
    UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
    if (self.haveHeadlines && indexPath.section == 0) {
        if (toOrientation == UIInterfaceOrientationPortrait ||
            toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(APP_WIDTH - 20, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            CGFloat descYPos = HEAD_NEWS_IMG_HEIGHT + 35;
            if (imageView.hidden) {
                descYPos = 30;
            }
            titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - 20, 20);
            descLabel.frame = CGRectMake(10, descYPos, APP_WIDTH - 20, descHeight);
            imageView.frame = CGRectMake((APP_WIDTH - HEAD_NEWS_IMG_WIDTH) / 2, 30,
                                         HEAD_NEWS_IMG_WIDTH, HEAD_NEWS_IMG_HEIGHT);
        } else {
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(APP_HEIGHT - 20, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            CGFloat descYPos = HEAD_NEWS_IMG_HEIGHT + 35;
            if (imageView.hidden) {
                descYPos = 30;
            }
            titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - 20, 20);
            descLabel.frame = CGRectMake(10, descYPos, APP_HEIGHT - 20, descHeight);
            imageView.frame = CGRectMake((APP_HEIGHT - HEAD_NEWS_IMG_WIDTH) / 2, 30,
                                         HEAD_NEWS_IMG_WIDTH, HEAD_NEWS_IMG_HEIGHT);
        }
    } else {
        if (toOrientation == UIInterfaceOrientationPortrait ||
            toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGFloat descWidth = APP_WIDTH - NEWS_IMG_WIDTH - 25;
            if (imageView.hidden) {
                descWidth = APP_WIDTH - 20;
            }
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - 20, 20);
            descLabel.frame = CGRectMake(10, 30, descWidth, descHeight);
            imageView.frame = CGRectMake(APP_WIDTH - NEWS_IMG_WIDTH - 10, 30, NEWS_IMG_WIDTH, NEWS_IMG_HEIGHT);
        } else {
            CGFloat descWidth = APP_HEIGHT - NEWS_IMG_WIDTH - 25;
            if (imageView.hidden) {
                descWidth = APP_HEIGHT - 20;
            }
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - 20, 20);
            descLabel.frame = CGRectMake(10, 30, descWidth, descHeight);
            imageView.frame = CGRectMake(APP_HEIGHT - NEWS_IMG_WIDTH - 10, 30, NEWS_IMG_WIDTH, NEWS_IMG_HEIGHT);
        }
    }
    
    // Set shadow for image view.
    imageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(2, 2);
    imageView.layer.shadowOpacity = 0.8;
    imageView.layer.shadowRadius = 3.0;
    imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.newspaper count] == 0) {
        return nil;
    }

    // Display the channels as section headings.
    NSString *headerTitle;
    if (self.haveHeadlines && section == 0) {
        headerTitle = NSLocalizedString(@"Headlines", @"The title of the headlines and guides section.");
    } else {
        NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:
                                       [NSIndexPath indexPathForRow:0 inSection:section]];
        headerTitle = ((NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section] objectAtIndex:0]).channel;
    }

    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 50)] autorelease];
    headerView.backgroundColor = NAV_BAR_BGCOLOR;
    
    UILabel *headerTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 1, APP_WIDTH - 20, 20)] autorelease];
    headerTitleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FSIZE];
    headerTitleLabel.text = headerTitle;
    headerTitleLabel.textColor = [UIColor whiteColor];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerTitleLabel];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.newspaper count] == 0) {
        return APP_HEIGHT - NAV_HEIGHT;
    }
    
    // Set cell height of the guides cell.
    if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
        CGFloat guidesHeight = [self.guides count] * 25 + 15;
        return (guidesHeight > 40) ? guidesHeight : 40;
    }
    
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if (toOrientation == UIInterfaceOrientationPortrait ||
        toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        // Set cell height of the headline cells.
        NewsObject *news;
        UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
        if (self.haveHeadlines && indexPath.section == 0) {
            news = (NewsObject *)[self.headlines objectAtIndex:indexPath.row];
            CGFloat descHeight = [news.desc sizeWithFont:font
                                       constrainedToSize:CGSizeMake(APP_WIDTH - 20, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap].height;
            if (news.imgurl) {
                return descHeight + HEAD_NEWS_IMG_HEIGHT + 40;
            } else {
                return descHeight + 35;
            }
        }
        
        // Set cell height of the normal cells.
        NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:indexPath];
        news = (NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section] objectAtIndex:arrayIndexPath.row];
        
        CGFloat descWidth = APP_WIDTH - 20;
        if (news.imgurl) {
            descWidth = APP_WIDTH - NEWS_IMG_WIDTH - 25;
        }
        CGFloat descHeight = [news.desc sizeWithFont:font
                                   constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeWordWrap].height;
        if (news.imgurl) {
            return (descHeight > NEWS_IMG_HEIGHT) ? (descHeight + 37) : NEWS_IMG_HEIGHT + 37;
        } else {
            return descHeight + 37;
        }
    } else {
        // Set cell height of the headline cells.
        NewsObject *news;
        UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
        if (self.haveHeadlines && indexPath.section == 0) {
            news = (NewsObject *)[self.headlines objectAtIndex:indexPath.row];
            CGFloat descHeight = [news.desc sizeWithFont:font
                                       constrainedToSize:CGSizeMake(APP_HEIGHT - 20, CGFLOAT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap].height;
            if (news.imgurl) {
                return descHeight + HEAD_NEWS_IMG_HEIGHT + 40;
            } else {
                return descHeight + 35;
            }
        }
        
        // Set cell height of the normal cells.
        NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:indexPath];
        news = (NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section] objectAtIndex:arrayIndexPath.row];
        
        CGFloat descWidth = APP_HEIGHT - 20;
        if (news.imgurl) {
            descWidth = APP_HEIGHT - NEWS_IMG_WIDTH - 25;
        }
        CGFloat descHeight = [news.desc sizeWithFont:font
                                   constrainedToSize:CGSizeMake(descWidth, CGFLOAT_MAX)
                                       lineBreakMode:UILineBreakModeWordWrap].height;
        if (news.imgurl) {
            return (descHeight > NEWS_IMG_HEIGHT) ? (descHeight + 37) : NEWS_IMG_HEIGHT + 37;
        } else {
            return descHeight + 37;
        }
    }
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
    if ([self.newspaper count] == 0) {
        return;
    }
    if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
        return;
    }
    NewsObject *news;
    if (self.haveHeadlines && indexPath.section == 0) {
        news = (NewsObject *)[self.headlines objectAtIndex:indexPath.row];
    } else {
        NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:indexPath];
        news = (NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section] objectAtIndex:arrayIndexPath.row];
    }
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.detailViewController.detailURL = [NSURL URLWithString:news.link];
    [self.navigationController pushViewController:appDelegate.detailViewController animated:YES];
}

#pragma mark -
#pragma mark Table cell image support

- (void)startImageDownload:(NSString *)imageURLString forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.imageURLString = imageURLString;
        imageDownloader.indexPath = indexPath;
        imageDownloader.delegate = self;
        [imageDownloadsInProgress setObject:imageDownloader forKey:indexPath];
        [imageDownloader startDownload];
        [imageDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their images yet
//
- (void)loadImagesForOnscreenRows
{
    if ([self.newspaper count] != 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            if (self.haveHeadlines && indexPath.section == 0 && indexPath.row == [self.headlines count]) {
                continue;
            }
            NewsObject *news;
            if (self.haveHeadlines && indexPath.section == 0) {
                news = (NewsObject *)[self.headlines objectAtIndex:indexPath.row];
            } else {
                NSIndexPath *arrayIndexPath = [self arrayIndexPathFromCellIndexPath:indexPath];
                news = (NewsObject *)[[self.newspaper objectAtIndex:arrayIndexPath.section]
                                      objectAtIndex:arrayIndexPath.row];
            }
            // avoid the image download if the news already has an image
            ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
            if (imageDownloader == nil || imageDownloader.image == nil) {
                [self startImageDownload:news.imgurl forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an image is ready to be displayed
//
- (void)newsImageDidLoad:(NSIndexPath *)indexPath
{
    ImageDownloader *imageDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (imageDownloader != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:imageDownloader.indexPath];
        // Display the newly loaded image
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kImageViewTag];
        imageView.image = imageDownloader.image;
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark -
#pragma mark TouchedLabel delegate

- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
