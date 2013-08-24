//
//  HelpViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-8-11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController <UIAlertViewDelegate> {
    NSURLConnection *webConnection;
    NSMutableData *webData;
    NSString *newAppURLString;
}

@property (nonatomic, retain) NSURLConnection *webConnection;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSString *newAppURLString;

- (IBAction)setButtonDownColor:(id)sender;
- (IBAction)loadWhatViewAction:(id)sender;
- (IBAction)loadHowViewAction:(id)sender;
- (IBAction)loadUpdateViewAction:(id)sender;
- (IBAction)loadContactViewAction:(id)sender;

- (void)handleError:(NSError *)error;

@end
