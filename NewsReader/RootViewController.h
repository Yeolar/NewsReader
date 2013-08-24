//
//  RootViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-15.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmlDownloader.h"


@interface RootViewController : UIViewController <XmlDownloaderDelegate, UIAlertViewDelegate> {
    NSURLConnection *webConnection;
    NSMutableData *webData;
    NSString *newAppURLString;
    
@private
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSURLConnection *webConnection;
@property (nonatomic, retain) NSMutableData *webData;
@property (nonatomic, retain) NSString *newAppURLString;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)setButtonDownColor:(id)sender;
- (IBAction)loadNewsViewAction:(id)sender;
- (IBAction)loadFeedsViewAction:(id)sender;
- (IBAction)loadPromoteViewAction:(id)sender;
//- (IBAction)loadCouponViewAction:(id)sender;
- (IBAction)loadManagerViewAction:(id)sender;
- (IBAction)loadHelpViewAction:(id)sender;

- (void)handleError:(NSError *)error;

@end
