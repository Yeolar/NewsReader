//
//  HelpViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-8-11.
//  Copyright 2011. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpDetailViewController.h"
#import "NewsReaderAppDelegate.h"
#import "Common.h"

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>


static NSUInteger const kWhatButtonTag = 601;
static NSUInteger const kHowButtonTag = 602;
static NSUInteger const kUpdateButtonTag = 603;
static NSUInteger const kContactButtonTag = 604;

static NSUInteger const kWhatButtonImageTag = 611;
static NSUInteger const kHowButtonImageTag = 612;
static NSUInteger const kUpdateButtonImageTag = 613;
static NSUInteger const kContactButtonImageTag = 614;

static NSString *checkVersionURLString = @"http://localhost/check-iphone-version/";
static NSString *appVersionString = @"1.0";

@implementation HelpViewController

@synthesize webConnection, webData, newAppURLString;

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
    
    self.title = NSLocalizedString(@"Help", @"The title of the help view.");
    
    // Set what button.
    UIButton *whatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [whatButton setTag:kWhatButtonTag];
    [whatButton setFrame:CGRectMake(10, 26, APP_WIDTH - 20, 60)];
    [whatButton setBackgroundColor:[UIColor whiteColor]];
    [whatButton setTitle:NSLocalizedString(@"What is the app", nil) forState:UIControlStateNormal];
    [whatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    whatButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    whatButton.layer.masksToBounds = YES;
    whatButton.layer.borderWidth = 1.0;
    whatButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    whatButton.layer.cornerRadius = 0.0;
    
    UIImageView *whatButtonImageView = [[UIImageView alloc] init];
    [whatButtonImageView setTag:kWhatButtonImageTag];
    [whatButtonImageView setImage:[UIImage imageNamed:@"arrow.png"]];
    [whatButton addSubview:whatButtonImageView];
    [whatButtonImageView release];
    
    [whatButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [whatButton addTarget:self action:@selector(loadWhatViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:whatButton];
    
    // Set how button.
    UIButton *howButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [howButton setTag:kHowButtonTag];
    [howButton setFrame:CGRectMake(10, 102, APP_WIDTH - 20, 60)];
    [howButton setBackgroundColor:[UIColor whiteColor]];
    [howButton setTitle:NSLocalizedString(@"How to use", nil) forState:UIControlStateNormal];
    [howButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    howButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    howButton.layer.masksToBounds = YES;
    howButton.layer.borderWidth = 1.0;
    howButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    howButton.layer.cornerRadius = 0.0;
    
    UIImageView *howButtonImageView = [[UIImageView alloc] init];
    [howButtonImageView setTag:kHowButtonImageTag];
    [howButtonImageView setImage:[UIImage imageNamed:@"arrow.png"]];
    [howButton addSubview:howButtonImageView];
    [howButtonImageView release];
    
    [howButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [howButton addTarget:self action:@selector(loadHowViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:howButton];
    
    // Set Update button.
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateButton setTag:kUpdateButtonTag];
    [updateButton setFrame:CGRectMake(10, 178, APP_WIDTH - 20, 60)];
    [updateButton setBackgroundColor:[UIColor whiteColor]];
    [updateButton setTitle:NSLocalizedString(@"Update", nil) forState:UIControlStateNormal];
    [updateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    updateButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    updateButton.layer.masksToBounds = YES;
    updateButton.layer.borderWidth = 1.0;
    updateButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    updateButton.layer.cornerRadius = 0.0;
    
    UIImageView *updateButtonImageView = [[UIImageView alloc] init];
    [updateButtonImageView setTag:kUpdateButtonImageTag];
    [updateButtonImageView setImage:[UIImage imageNamed:@"arrow.png"]];
    [updateButton addSubview:updateButtonImageView];
    [updateButtonImageView release];
    
    [updateButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [updateButton addTarget:self action:@selector(loadUpdateViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateButton];

    // Set contact button.
    UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactButton setTag:kContactButtonTag];
    [contactButton setFrame:CGRectMake(10, 254, APP_WIDTH - 20, 60)];
    [contactButton setBackgroundColor:[UIColor whiteColor]];
    [contactButton setTitle:NSLocalizedString(@"Contact", nil) forState:UIControlStateNormal];
    [contactButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    contactButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    
    contactButton.layer.masksToBounds = YES;
    contactButton.layer.borderWidth = 1.0;
    contactButton.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:1.0] CGColor];
    contactButton.layer.cornerRadius = 0.0;
    
    UIImageView *contactButtonImageView = [[UIImageView alloc] init];
    [contactButtonImageView setTag:kContactButtonImageTag];
    [contactButtonImageView setImage:[UIImage imageNamed:@"arrow.png"]];
    [contactButton addSubview:contactButtonImageView];
    [contactButtonImageView release];
    
    [contactButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
    [contactButton addTarget:self action:@selector(loadContactViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contactButton];
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
    
    UIButton *whatButton = (UIButton *)[self.view viewWithTag:kWhatButtonTag];
    UIButton *howButton = (UIButton *)[self.view viewWithTag:kHowButtonTag];
    UIButton *updateButton = (UIButton *)[self.view viewWithTag:kUpdateButtonTag];
    UIButton *contactButton = (UIButton *)[self.view viewWithTag:kContactButtonTag];
    
    UIImageView *whatButtonImageView = (UIImageView *)[whatButton viewWithTag:kWhatButtonImageTag];
    UIImageView *howButtonImageView = (UIImageView *)[howButton viewWithTag:kHowButtonImageTag];
    UIImageView *updateButtonImageView = (UIImageView *)[updateButton viewWithTag:kUpdateButtonImageTag];
    UIImageView *contactButtonImageView = (UIImageView *)[contactButton viewWithTag:kContactButtonImageTag];
    
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        whatButton.frame = CGRectMake(10, 26, APP_WIDTH - 20, 60);
        howButton.frame = CGRectMake(10, 102, APP_WIDTH - 20, 60);
        updateButton.frame = CGRectMake(10, 178, APP_WIDTH - 20, 60);
        contactButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        
        whatButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        howButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        updateButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        contactButtonImageView.frame = CGRectMake(15, 5, 50, 50);
    } else {
        whatButton.frame = CGRectMake(10, 14, APP_HEIGHT - 20, 40);
        howButton.frame = CGRectMake(10, 64, APP_HEIGHT - 20, 40);
        updateButton.frame = CGRectMake(10, 114, APP_HEIGHT - 20, 40);
        contactButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        
        whatButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        howButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        updateButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        contactButtonImageView.frame = CGRectMake(30, 0, 40, 40);
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
    
    UIButton *whatButton = (UIButton *)[self.view viewWithTag:kWhatButtonTag];
    UIButton *howButton = (UIButton *)[self.view viewWithTag:kHowButtonTag];
    UIButton *updateButton = (UIButton *)[self.view viewWithTag:kUpdateButtonTag];
    UIButton *contactButton = (UIButton *)[self.view viewWithTag:kContactButtonTag];
    
    UIImageView *whatButtonImageView = (UIImageView *)[whatButton viewWithTag:kWhatButtonImageTag];
    UIImageView *howButtonImageView = (UIImageView *)[howButton viewWithTag:kHowButtonImageTag];
    UIImageView *updateButtonImageView = (UIImageView *)[updateButton viewWithTag:kUpdateButtonImageTag];
    UIImageView *contactButtonImageView = (UIImageView *)[contactButton viewWithTag:kContactButtonImageTag];
    
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        whatButton.frame = CGRectMake(10, 26, APP_WIDTH - 20, 60);
        howButton.frame = CGRectMake(10, 102, APP_WIDTH - 20, 60);
        updateButton.frame = CGRectMake(10, 178, APP_WIDTH - 20, 60);
        contactButton.frame = CGRectMake(10, 254, APP_WIDTH - 20, 60);
        
        whatButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        howButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        updateButtonImageView.frame = CGRectMake(15, 5, 50, 50);
        contactButtonImageView.frame = CGRectMake(15, 5, 50, 50);
    } else {
        whatButton.frame = CGRectMake(10, 14, APP_HEIGHT - 20, 40);
        howButton.frame = CGRectMake(10, 64, APP_HEIGHT - 20, 40);
        updateButton.frame = CGRectMake(10, 114, APP_HEIGHT - 20, 40);
        contactButton.frame = CGRectMake(10, 164, APP_HEIGHT - 20, 40);
        
        whatButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        howButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        updateButtonImageView.frame = CGRectMake(30, 0, 40, 40);
        contactButtonImageView.frame = CGRectMake(30, 0, 40, 40);
    }
}

- (IBAction)setButtonDownColor:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = ROOT_BUTTON_BGCOLOR;
}

- (IBAction)loadWhatViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.helpDetailViewController.htmlFileName = @"what";
    [self.navigationController pushViewController:appDelegate.helpDetailViewController animated:YES];
}

- (IBAction)loadHowViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.helpDetailViewController.htmlFileName = @"how";
    [self.navigationController pushViewController:appDelegate.helpDetailViewController animated:YES];
}

- (IBAction)loadUpdateViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:[NSURL URLWithString:checkVersionURLString]] delegate:self];
    self.webConnection = conn;
    [conn release];
    
    NSAssert(self.webConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)loadContactViewAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor whiteColor];
    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.helpDetailViewController.htmlFileName = @"contact";
    [self.navigationController pushViewController:appDelegate.helpDetailViewController animated:YES];
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
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"The Latest Version Already"
                                                                message:@"The application is the latest version already."
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"The title of the cancel button.")
                                                      otherButtonTitles:nil, nil];
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
