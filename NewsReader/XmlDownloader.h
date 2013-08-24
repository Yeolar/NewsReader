//
//  XmlDownloader.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

@protocol XmlDownloaderDelegate;

@interface XmlDownloader : NSObject {
    NSUInteger parserTag;
    NSString *xmlURLString;
    NSURLConnection *xmlConnection;
    NSMutableData *xmlData;
    id <XmlDownloaderDelegate> delegate;
}

@property (nonatomic, assign) NSUInteger parserTag;
@property (nonatomic, retain) NSString *xmlURLString;
@property (nonatomic, retain) NSURLConnection *xmlConnection;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, assign) id <XmlDownloaderDelegate> delegate;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol XmlDownloaderDelegate

- (void)xmlDidDownload:(NSMutableData *)data withParserTag:(NSUInteger)parserTag;
- (void)xmlDownloadError:(NSError *)error withParserTag:(NSUInteger)parserTag;

@end