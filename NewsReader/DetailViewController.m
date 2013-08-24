//
//  DetailViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import "DetailViewController.h"
#import "Settings.h"
#import "Common.h"


@implementation DetailViewController

@synthesize detailView, loadingView, activityInicatorView, detailURL, fontSize;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.detailView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT)];
        self.detailView.delegate = self;
        [self.view addSubview:self.detailView];
        
        self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT)];
        [self.loadingView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.loadingView];
        
        self.activityInicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self.activityInicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingView addSubview:self.activityInicatorView];
        
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:
                                        NSLocalizedString(@"Share", @"The title of the share button.")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(shareNews)];
        
        UISegmentedControl *segmentedControl =
        [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                   NSLocalizedString(@"Normal", @"Button to set font normal"),
                                                   NSLocalizedString(@"Large", @"Button to set font large."), nil]];
        segmentedControl.frame = CGRectMake(0, 0, 90, 30);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segmentedControl addTarget:self
                             action:@selector(changeFontSizeAction:)
                   forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *fontSizeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        [segmentedControl release];
        
        self.navigationItem.rightBarButtonItem = shareButton;
        [shareButton release];
        [fontSizeButton release];
    }
    return self;
}

- (void)dealloc
{
    [detailView release];
    [loadingView release];
    [activityInicatorView release];
    [detailURL release];
    [managedObjectContext release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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

    self.title = NSLocalizedString(@"News Detail", @"The title of the news detail view.");
    
    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.detailView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
        self.loadingView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
    } else {
        UIDevice* thisDevice = [UIDevice currentDevice];
        if (thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.detailView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
            self.loadingView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
        } else {
            self.detailView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
            self.loadingView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
        }
    }

    UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView;
    if (self.fontSize == 100) {
        segmentedControl.selectedSegmentIndex = 0;
    } else {
        segmentedControl.selectedSegmentIndex = 1;
    }
    
    [self.detailView loadRequest:[NSURLRequest requestWithURL:detailURL]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.detailView loadHTMLString:@"" baseURL:nil];   // to clean the page
    
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Settings"
                                           inManagedObjectContext:self.managedObjectContext];
    Settings *settings = [[Settings alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
    settings.webfsize = [NSNumber numberWithInt:self.fontSize];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = ent;
    
    NSError *error = nil;
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedItems count] != 0) {
        // to copy other settings before delete ...
        for (Settings *oldSettings in fetchedItems) {
            [self.managedObjectContext deleteObject:oldSettings];
        }
    }
    [self.managedObjectContext insertObject:settings];
    
    if (![managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [fetchRequest release];
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
        self.detailView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
        self.loadingView.frame = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - NAV_HEIGHT);
    } else {
        UIDevice* thisDevice = [UIDevice currentDevice];
        if (thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.detailView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
            self.loadingView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT);
        } else {
            self.detailView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
            self.loadingView.frame = CGRectMake(0, 0, APP_HEIGHT, APP_WIDTH - NAV_HEIGHT_IPHONE_LA);
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityInicatorView setCenter:self.loadingView.center];

    self.loadingView.hidden = NO;
    
    [self.activityInicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self changeFontSize];

    [self.activityInicatorView stopAnimating];
    
    self.loadingView.hidden = YES;
}

/*
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}
*/

- (void)changeFontSize
{
    if (self.fontSize == 100) {
        [self.detailView stringByEvaluatingJavaScriptFromString:
         @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='100%'"];
    } else {
        [self.detailView stringByEvaluatingJavaScriptFromString:
         @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='120%'"];
    }
}

- (IBAction)changeFontSizeAction:(id)sender
{
    if (((UISegmentedControl *)sender).selectedSegmentIndex == 0) {
        self.fontSize = 100;
    } else {
        self.fontSize = 120;
    }
    [self changeFontSize];
}

- (void)shareNews
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"The title of the cancel button.")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Share by Email", nil),
                                                                      NSLocalizedString(@"Share by SMS", nil), nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == 0) {
        MFMailComposeViewController *mailComposeView = [[MFMailComposeViewController alloc] init];
        [mailComposeView setMailComposeDelegate:self];
        [mailComposeView setMessageBody:@"我刚才看到了一条好玩的新闻，你也来看吧！ yeolar.com"
                                 isHTML:NO];
        [self presentModalViewController:mailComposeView animated:YES];
        [mailComposeView release];
    } else if (buttonIndex == 1) {
        MFMessageComposeViewController *smsComposeView = [[MFMessageComposeViewController alloc] init];
        if ([MFMessageComposeViewController canSendText]) {
            [smsComposeView setMessageComposeDelegate:self];
            [smsComposeView setBody:@"我刚才看到了一条好玩的新闻，你也来看吧！ yeolar.com"];
            [self presentModalViewController:smsComposeView animated:YES];
        }
        [smsComposeView release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if (result == MFMailComposeResultFailed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Error"
                                                            message:@"Failed to send the Email"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultFailed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Send Error"
                                                            message:@"Failed to send the message"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
