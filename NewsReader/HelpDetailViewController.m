//
//  HelpDetailViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-8-11.
//  Copyright 2011. All rights reserved.
//

#import "HelpDetailViewController.h"
#import "Common.h"


@implementation HelpDetailViewController

@synthesize webView, htmlFileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT)];
        [self.view addSubview:self.webView];
    }
    return self;
}

- (void)dealloc
{
    [webView release];
    [htmlFileName release];
    
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
    
    if ([self.htmlFileName isEqualToString:@"what"]) {
        self.title = NSLocalizedString(@"What", nil);
    } else if ([self.htmlFileName isEqualToString:@"how"]) {
        self.title = NSLocalizedString(@"How", nil);
    } else if ([self.htmlFileName isEqualToString:@"contact"]) {
        self.title = NSLocalizedString(@"Contact", nil);
    }

    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.webView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
    } else {
        UIDevice* thisDevice = [UIDevice currentDevice];
        if (thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.webView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
        } else {
            self.webView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
        }
    }

    NSString *path = [[NSBundle mainBundle] pathForResource:self.htmlFileName ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
	NSString *htmlString = [[NSString alloc] initWithData: 
                            [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[self.webView loadHTMLString:htmlString baseURL:nil];
	[htmlString release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView loadHTMLString:@"" baseURL:nil];   // to clean the page
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
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.webView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
    } else {
        UIDevice* thisDevice = [UIDevice currentDevice];
        if (thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.webView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
        } else {
            self.webView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
        }
    }
}

@end
