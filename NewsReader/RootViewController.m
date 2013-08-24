//
//  RootViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-15.
//  Copyright 2011. All rights reserved.
//

#import "RootViewController.h"
#import "NewsViewController.h"
#import "FeedsViewController.h"
#import "PromotesViewController.h"
#import "ManagerViewController.h"
#import "HelpViewController.h"
#import "DetailViewController.h"
#import "NewsReaderAppDelegate.h"
#import "NewsParseOperation.h"
#import "FeedsParseOperation.h"
#import "PromotesParseOperation.h"
#import "ProductsParseOperation.h"
#import "Product.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>


static NSUInteger const kNewsListParserTag = 2;
static NSUInteger const kFeedListParserTag = 3;
static NSUInteger const kPromoteListParserTag = 4;
static NSUInteger const kProductListParserTag = 5;

static NSUInteger const kNewsButtonTag = 101;
static NSUInteger const kFeedsButtonTag = 102;
static NSUInteger const kPromoteButtonTag = 103;
//static NSUInteger const kCouponButtonTag = 104;
static NSUInteger const kManagerButtonTag = 105;
static NSUInteger const kHelpButtonTag = 106;

static NSUInteger const kNewsButtonImageTag = 111;
static NSUInteger const kFeedsButtonImageTag = 112;
static NSUInteger const kPromoteButtonImageTag = 113;
//static NSUInteger const kCouponButtonImageTag = 114;
static NSUInteger const kManagerButtonImageTag = 115;
static NSUInteger const kHelpButtonImageTag = 116;

static NSString *checkVersionURLString = @"http://localhost/check-iphone-version/";
static NSString *todayNewsURLString = @"http://localhost/gen-xml-news-list/?productIds=%@";
static NSString *feedListURLString = @"http://localhost/gen-xml-newspaper/?productIds=%@";
static NSString *promoteURLString = @"http://localhost/gen-xml-promote-newspaper/";
//static NSString *couponURLString = @"http://localhost/coupon/";
static NSString *productListURLString = @"http://localhost/gen-xml-product/";

static NSString *appVersionString = @"1.0";

@implementation RootViewController

@synthesize webConnection, webData, newAppURLString, managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [webConnection cancel];
    [webConnection release];
    [webData release];
    [newAppURLString release];
    [managedObjectContext release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddNewsNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewsErrorNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFeedsErrorNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPromotesErrorNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductsErrorNotif object:nil];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Root", @"The title of the root view.");
    
    // Set newspaper button.
    UIButton *newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newsButton setTag:kNewsButtonTag];
    [newsButton setFrame:CGRectMake(10, 26, APP_WIDTH - 20, 60)];
    [newsButton setBackgroundColor:[UIColor whiteColor]];
    [newsButton setTitle:NSLocalizedString(@"Today News", @"Todday news list.") forState:UIControlStateNormal];
    [newsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    newsButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    newsButton.layer.masksToBounds = YES;
    newsButton.layer.borderWidth = 1.0;
    newsButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    newsButton.layer.cornerRadius = 0.0;

    UIImageView *newsButtonImageView = [[UIImageView alloc] init];
    [newsButtonImageView setTag:kNewsButtonImageTag];
    [newsButtonImageView setImage:[UIImage imageNamed:@"newspaper.png"]];
    [newsButton addSubview:newsButtonImageView];
    [newsButtonImageView release];

    [newsButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [newsButton addTarget:self action:@selector(loadNewsViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newsButton];

    // Set newspaper list button.
    UIButton *feedsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [feedsButton setTag:kFeedsButtonTag];
    [feedsButton setFrame:CGRectMake(10, 102, APP_WIDTH - 20, 60)];
    [feedsButton setBackgroundColor:[UIColor whiteColor]];
    [feedsButton setTitle:NSLocalizedString(@"Newspaper List", @"The title of the newspaper list view.")
                 forState:UIControlStateNormal];
    [feedsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    feedsButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];

    feedsButton.layer.masksToBounds = YES;
    feedsButton.layer.borderWidth = 1.0;
    feedsButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    feedsButton.layer.cornerRadius = 0.0;

    UIImageView *feedsButtonImageView = [[UIImageView alloc] init];
    [feedsButtonImageView setTag:kFeedsButtonImageTag];
    [feedsButtonImageView setImage:[UIImage imageNamed:@"np_list.png"]];
    [feedsButton addSubview:feedsButtonImageView];
    [feedsButtonImageView release];
    
    [feedsButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [feedsButton addTarget:self action:@selector(loadFeedsViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:feedsButton];

    // Set promote button.
    UIButton *promoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [promoteButton setTag:kPromoteButtonTag];
    [promoteButton setFrame:CGRectMake(10, 178, APP_WIDTH - 20, 60)];
    [promoteButton setBackgroundColor:[UIColor whiteColor]];
    [promoteButton setTitle:NSLocalizedString(@"Promote List", @"The title of the promote list view.")
                   forState:UIControlStateNormal];
    [promoteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    promoteButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];

    promoteButton.layer.masksToBounds = YES;
    promoteButton.layer.borderWidth = 1.0;
    promoteButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    promoteButton.layer.cornerRadius = 0.0;

    UIImageView *promoteButtonImageView = [[UIImageView alloc] init];
    [promoteButtonImageView setTag:kPromoteButtonImageTag];
    [promoteButtonImageView setImage:[UIImage imageNamed:@"promote.png"]];
    [promoteButton addSubview:promoteButtonImageView];
    [promoteButtonImageView release];
    
    [promoteButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [promoteButton addTarget:self action:@selector(loadPromoteViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:promoteButton];
/*
    // Set coupon button.
    UIButton *couponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [couponButton setTag:kCouponButtonTag];
    [couponButton setFrame:CGRectMake(10, 254, APP_WIDTH - 20, 60)];
    [couponButton setBackgroundColor:[UIColor whiteColor]];
    [couponButton setTitle:NSLocalizedString(@"Coupon", @"The title of the coupon view.")
                   forState:UIControlStateNormal];
    [couponButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    couponButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    couponButton.layer.masksToBounds = YES;
    couponButton.layer.borderWidth = 1.0;
    couponButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    couponButton.layer.cornerRadius = 0.0;
    
    UIImageView *couponButtonImageView = [[UIImageView alloc] init];
    [couponButtonImageView setTag:kCouponButtonImageTag];
    [couponButtonImageView setImage:[UIImage imageNamed:@"coupon.png"]];
    [couponButton addSubview:couponButtonImageView];
    [couponButtonImageView release];
    
    [couponButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [couponButton addTarget:self action:@selector(loadCouponViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:couponButton];
*/
    // Set product manager button.
    UIButton *managerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [managerButton setTag:kManagerButtonTag];
    [managerButton setFrame:CGRectMake(10, 254, APP_WIDTH - 20, 60)];
    [managerButton setBackgroundColor:[UIColor whiteColor]];
    [managerButton setTitle:NSLocalizedString(@"Product Manager", @"The title of the product manager view.")
                   forState:UIControlStateNormal];
    [managerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    managerButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    managerButton.layer.masksToBounds = YES;
    managerButton.layer.borderWidth = 1.0;
    managerButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    managerButton.layer.cornerRadius = 0.0;
    
    UIImageView *managerButtonImageView = [[UIImageView alloc] init];
    [managerButtonImageView setTag:kManagerButtonImageTag];
    [managerButtonImageView setImage:[UIImage imageNamed:@"product.png"]];
    [managerButton addSubview:managerButtonImageView];
    [managerButtonImageView release];
    
    [managerButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [managerButton addTarget:self action:@selector(loadManagerViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:managerButton];

    // Set help button.
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpButton setTag:kHelpButtonTag];
    [helpButton setFrame:CGRectMake(10, 330, APP_WIDTH - 20, 60)];
    [helpButton setBackgroundColor:[UIColor whiteColor]];
    [helpButton setTitle:NSLocalizedString(@"Help", @"The title of the help view.")
                   forState:UIControlStateNormal];
    [helpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    helpButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    helpButton.layer.masksToBounds = YES;
    helpButton.layer.borderWidth = 1.0;
    helpButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    helpButton.layer.cornerRadius = 0.0;
    
    UIImageView *helpButtonImageView = [[UIImageView alloc] init];
    [helpButtonImageView setTag:kHelpButtonImageTag];
    [helpButtonImageView setImage:[UIImage imageNamed:@"help.png"]];
    [helpButton addSubview:helpButtonImageView];
    [helpButtonImageView release];
    
    [helpButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [helpButton addTarget:self action:@selector(loadHelpViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNews:)
                                                 name:kAddNewsNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newsError:)
                                                 name:kNewsErrorNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedsError:)
                                                 name:kFeedsErrorNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(promotesError:)
                                                 name:kPromotesErrorNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productsError:)
                                                 name:kProductsErrorNotif
                                               object:nil];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:[NSURL URLWithString:checkVersionURLString]] delegate:self];
    self.webConnection = conn;
    [conn release];
    
    NSAssert(self.webConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    
    UIButton *newsButton = (UIButton *)[self.view viewWithTag:kNewsButtonTag];
    UIButton *feedsButton = (UIButton *)[self.view viewWithTag:kFeedsButtonTag];
    UIButton *promoteButton = (UIButton *)[self.view viewWithTag:kPromoteButtonTag];
    //UIButton *couponButton = (UIButton *)[self.view viewWithTag:kCouponButtonTag];
    UIButton *managerButton = (UIButton *)[self.view viewWithTag:kManagerButtonTag];
    UIButton *helpButton = (UIButton *)[self.view viewWithTag:kHelpButtonTag];
    
    UIImageView *newsButtonImageView = (UIImageView *)[newsButton viewWithTag:kNewsButtonImageTag];
    UIImageView *feedsButtonImageView = (UIImageView *)[feedsButton viewWithTag:kFeedsButtonImageTag];
    UIImageView *promoteButtonImageView = (UIImageView *)[promoteButton viewWithTag:kPromoteButtonImageTag];
    //UIImageView *couponButtonImageView = (UIImageView *)[couponButton viewWithTag:kCouponButtonImageTag];
    UIImageView *managerButtonImageView = (UIImageView *)[managerButton viewWithTag:kManagerButtonImageTag];
    UIImageView *helpButtonImageView = (UIImageView *)[helpButton viewWithTag:kHelpButtonImageTag];
    
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        newsButton.frame = CGRectMake(10, 26, APP_WIDTH - 20, 60);
        feedsButton.frame = CGRectMake(10, 102, APP_WIDTH - 20, 60);
        promoteButton.frame = CGRectMake(10, 178, APP_WIDTH - 20, 60);
        //couponButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        managerButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        helpButton.frame = CGRectMake(10, 330, APP_WIDTH - 20, 60);
        
        newsButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        feedsButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        promoteButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        //couponButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        managerButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        helpButtonImageView.frame = CGRectMake(15, 5, 50, 50);
    } else {
        newsButton.frame = CGRectMake(10, 14, APP_HEIGHT - 20, 40);
        feedsButton.frame = CGRectMake(10, 64, APP_HEIGHT - 20, 40);
        promoteButton.frame = CGRectMake(10, 114, APP_HEIGHT - 20, 40);
        //couponButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        managerButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        helpButton.frame = CGRectMake(10, 214, APP_HEIGHT - 20, 40);

        newsButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        feedsButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        promoteButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        //couponButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        managerButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        helpButtonImageView.frame = CGRectMake(30, 0, 40, 40);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    
    UIButton *newsButton = (UIButton *)[self.view viewWithTag:kNewsButtonTag];
    UIButton *feedsButton = (UIButton *)[self.view viewWithTag:kFeedsButtonTag];
    UIButton *promoteButton = (UIButton *)[self.view viewWithTag:kPromoteButtonTag];
    //UIButton *couponButton = (UIButton *)[self.view viewWithTag:kCouponButtonTag];
    UIButton *managerButton = (UIButton *)[self.view viewWithTag:kManagerButtonTag];
    UIButton *helpButton = (UIButton *)[self.view viewWithTag:kHelpButtonTag];
    
    UIImageView *newsButtonImageView = (UIImageView *)[newsButton viewWithTag:kNewsButtonImageTag];
    UIImageView *feedsButtonImageView = (UIImageView *)[feedsButton viewWithTag:kFeedsButtonImageTag];
    UIImageView *promoteButtonImageView = (UIImageView *)[promoteButton viewWithTag:kPromoteButtonImageTag];
    //UIImageView *couponButtonImageView = (UIImageView *)[couponButton viewWithTag:kCouponButtonImageTag];
    UIImageView *managerButtonImageView = (UIImageView *)[managerButton viewWithTag:kManagerButtonImageTag];
    UIImageView *helpButtonImageView = (UIImageView *)[helpButton viewWithTag:kHelpButtonImageTag];
    
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        newsButton.frame = CGRectMake(10, 26, APP_WIDTH - 20, 60);
        feedsButton.frame = CGRectMake(10, 102, APP_WIDTH - 20, 60);
        promoteButton.frame = CGRectMake(10, 178, APP_WIDTH - 20, 60);
        //couponButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        managerButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        helpButton.frame = CGRectMake(10, 330, APP_WIDTH - 20, 60);
        
        newsButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        feedsButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        promoteButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        //couponButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        managerButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        helpButtonImageView.frame = CGRectMake(15, 5, 50, 50);
    } else {
        newsButton.frame = CGRectMake(10, 14, APP_HEIGHT - 20, 40);
        feedsButton.frame = CGRectMake(10, 64, APP_HEIGHT - 20, 40);
        promoteButton.frame = CGRectMake(10, 114, APP_HEIGHT - 20, 40);
        //couponButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        managerButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        helpButton.frame = CGRectMake(10, 214, APP_HEIGHT - 20, 40);
        
        newsButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        feedsButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        promoteButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        //couponButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        managerButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        helpButtonImageView.frame = CGRectMake(30, 0, 40, 40);
    }
}

- (IBAction)setButtonDownColor:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = ROOT_BUTTON_BGCOLOR;
}

- (IBAction)loadNewsViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];

    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate.newsViewController.haveHeadlines = NO;

    appDelegate.newsViewController.loadingView.hidden = NO;
    //[appDelegate.newsViewController.view bringSubviewToFront:appDelegate.newsViewController.loadingView];
    [appDelegate.newsViewController.activityInicatorView startAnimating];
    
    appDelegate.newsViewController.newspaper = [NSMutableArray array];
    [appDelegate.newsViewController.tableView reloadData];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Product"
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"subscribed", nil];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subscribed = %@", [NSNumber numberWithBool:YES]];
    
    NSError *error = nil;
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    NSMutableString *productIds = [[[NSMutableString alloc] initWithString:@""] autorelease];
    Product *product;
    for (product in fetchedItems) {
        [productIds appendString:[product.pdid stringValue]];
        [productIds appendString:@","];
    }
    if ([productIds length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  NSLocalizedString(@"No Product Error",
                                                    @"Title for alert displayed when no product selected.")
                                                            message:
                                  NSLocalizedString(@"No Product subscribed currently.",
                                                    @"Description for alert displayed when no product selected.")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    [productIds deleteCharactersInRange:NSMakeRange([productIds length] - 1, 1)];

    XmlDownloader *xmlDownloader = [[XmlDownloader alloc] init];
    xmlDownloader.parserTag = kNewsListParserTag;
    xmlDownloader.xmlURLString = [NSString stringWithFormat:todayNewsURLString, productIds];
    xmlDownloader.delegate = self;
    [xmlDownloader startDownload];
    [xmlDownloader release];
    
    [self.navigationController pushViewController:appDelegate.newsViewController animated:YES];
}

- (IBAction)loadFeedsViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Product"
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"subscribed", nil];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"subscribed = %@", [NSNumber numberWithBool:YES]];
    
    NSError *error = nil;
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    NSMutableString *productIds = [[[NSMutableString alloc] initWithString:@""] autorelease];
    Product *product;
    for (product in fetchedItems) {
        [productIds appendString:[product.pdid stringValue]];
        [productIds appendString:@","];
    }
    if ([productIds length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                                  NSLocalizedString(@"No Product Error",
                                                    @"Title for alert displayed when no product selected.")
                                                            message:
                                  NSLocalizedString(@"No Product subscribed currently.",
                                                    @"Description for alert displayed when no product selected.")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    [productIds deleteCharactersInRange:NSMakeRange([productIds length] - 1, 1)];

    XmlDownloader *xmlDownloader = [[XmlDownloader alloc] init];
    xmlDownloader.parserTag = kFeedListParserTag;
    xmlDownloader.xmlURLString = [NSString stringWithFormat:feedListURLString, productIds];
    xmlDownloader.delegate = self;
    [xmlDownloader startDownload];
    [xmlDownloader release];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.feedsViewController animated:YES];
}

- (IBAction)loadPromoteViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];

    XmlDownloader *xmlDownloader = [[XmlDownloader alloc] init];
    xmlDownloader.parserTag = kPromoteListParserTag;
    xmlDownloader.xmlURLString = promoteURLString;
    xmlDownloader.delegate = self;
    [xmlDownloader startDownload];
    [xmlDownloader release];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.promotesViewController animated:YES];
}
/*
- (IBAction)loadCouponViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];

    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.detailViewController.detailURL = [NSURL URLWithString:couponURLString];
    [self.navigationController pushViewController:appDelegate.detailViewController animated:YES];
}
*/
- (IBAction)loadManagerViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    XmlDownloader *xmlDownloader = [[XmlDownloader alloc] init];
    xmlDownloader.parserTag = kProductListParserTag;
    xmlDownloader.xmlURLString = productListURLString;
    xmlDownloader.delegate = self;
    [xmlDownloader startDownload];
    [xmlDownloader release];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.managerViewController animated:YES];
}

- (IBAction)loadHelpViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.helpViewController animated:YES];
}

- (void)xmlDidDownload:(NSMutableData *)data withParserTag:(NSUInteger)parserTag
{    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (parserTag == kNewsListParserTag) {
        NewsParseOperation *parseOperation = [[NewsParseOperation alloc] initWithData:data];
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        // NewsParseOperation also modified Feed entity, merge changes and reload data.
        [[NSNotificationCenter defaultCenter] addObserver:appDelegate.feedsViewController
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:parseOperation.managedObjectContext];
    } else if (parserTag == kFeedListParserTag) {
        FeedsParseOperation *parseOperation = [[FeedsParseOperation alloc] initWithData:data];
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        [[NSNotificationCenter defaultCenter] addObserver:appDelegate.feedsViewController
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:parseOperation.managedObjectContext];
    } else if (parserTag == kPromoteListParserTag) {
        PromotesParseOperation *parseOperation = [[PromotesParseOperation alloc] initWithData:data];
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        [[NSNotificationCenter defaultCenter] addObserver:appDelegate.promotesViewController
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:parseOperation.managedObjectContext];
    } else if (parserTag == kProductListParserTag) {
        ProductsParseOperation *parseOperation = [[ProductsParseOperation alloc] initWithData:data];
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        [[NSNotificationCenter defaultCenter] addObserver:appDelegate.managerViewController
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:parseOperation.managedObjectContext];
    }
}

- (void)xmlDownloadError:(NSError *)error withParserTag:(NSUInteger)parserTag
{
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (parserTag == kNewsListParserTag) {
        [appDelegate.newsViewController.activityInicatorView stopAnimating];
        [self handleError:error];
    }
}

// The NSOperation "NewsParseOperation" calls addNews: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.
//
- (void)addNewsToList:(NSArray *)newsArray
{
    // insert the news into our newsViewController's data source (for KVO purposes)
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.newsViewController insertNews:newsArray];
}

// Our NSNotification callback from the running NSOperation to add the news
//
- (void)addNews:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self addNewsToList:[[notif userInfo] valueForKey:kNewsResultsKey]];
}

// Handle errors by showing an alert to the user.
//
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                              NSLocalizedString(@"Error Title",
                                                @"Title for alert displayed when download or parse error occurs.")
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)newsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kNewsMsgErrorKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)feedsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kFeedsMsgErrorKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)promotesError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kPromotesMsgErrorKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)productsError:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kProductsMsgErrorKey]];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful.
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (([httpResponse statusCode]/100) == 2) {
        self.webData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"No Connection Error",
                                                    @"Error message displayed when not connected to the Internet.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.webConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.webConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([self.webData length] > 0) {
        NSString *checkVersionString = [[NSString alloc] initWithData:self.webData encoding:NSASCIIStringEncoding];
        NSArray *checkVersionArray = [checkVersionString componentsSeparatedByString:@";"];
        NSAssert(checkVersionArray.count == 2, @"Wrong format of checkVersionString, more than one comma found.");
        
        NSString *newAppVersionString = [checkVersionArray objectAtIndex:0];
        self.newAppURLString = [NSString stringWithString:[checkVersionArray lastObject]];
        
        if ([newAppVersionString floatValue] > [appVersionString floatValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Version Available"
                                                                message:@"A new version of the application is released, please update from iTunes."
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"The title of the cancel button.")
                                                      otherButtonTitles:NSLocalizedString(@"Update", @"The title of the update button."), nil];
            [alertView show];
            [alertView release];
        }
    }

    // xmlData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.webData = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.newAppURLString]];
    }
}

@end
