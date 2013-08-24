//
//  DetailViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface DetailViewController : UIViewController
<UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    UIWebView *detailView;
    UIView *loadingView;
    UIActivityIndicatorView *activityInicatorView;
    
    NSURL *detailURL;
    NSInteger fontSize;
    
@private
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UIWebView *detailView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityInicatorView;

@property (nonatomic, retain) NSURL *detailURL;
@property (nonatomic, assign) NSInteger fontSize;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)changeFontSize;
- (IBAction)changeFontSizeAction:(id)sender;

@end
