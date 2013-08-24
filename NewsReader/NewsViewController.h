//
//  NewsViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "TouchedLabel.h"


@class NewsObject;

@interface NewsViewController : UITableViewController
<UIScrollViewDelegate, ImageDownloaderDelegate, TouchedLabelDelegate> {
    UIView *loadingView;
    UIActivityIndicatorView *activityInicatorView;

    NSMutableArray *newspaper;
    NSArray *headlines;
    NSMutableDictionary *guides;
    BOOL haveHeadlines;
    NSMutableDictionary *imageDownloadsInProgress;  // the set of ImageDownloader objects for each news
}

@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityInicatorView;

@property (nonatomic, retain) NSMutableArray *newspaper;
@property (nonatomic, retain) NSArray *headlines;
@property (nonatomic, retain) NSMutableDictionary *guides;
@property (nonatomic, assign) BOOL haveHeadlines;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

- (void)insertNews:(NSArray *)newsArray;   // addition method of news (for KVO purposes)

- (void)newsImageDidLoad:(NSIndexPath *)indexPath;

- (void)startImageDownload:(NSString *)imageURLString forIndexPath:(NSIndexPath *)indexPath;

- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath;

@end
