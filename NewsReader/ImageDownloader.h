//
//  ImageDownloader.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-20.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject {
    UIImage *image;
    NSString *imageURLString;
    NSIndexPath *indexPath;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    id <ImageDownloaderDelegate> delegate;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ImageDownloaderDelegate 

- (void)newsImageDidLoad:(NSIndexPath *)indexPath;

@end