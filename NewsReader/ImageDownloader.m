//
//  ImageDownloader.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-20.
//  Copyright 2011. All rights reserved.
//

#import "ImageDownloader.h"
#import "Common.h"


@implementation ImageDownloader

@synthesize image, imageURLString, indexPath, activeDownload, imageConnection, delegate;

- (void)dealloc
{
    [image release];
    [imageURLString release];
    [indexPath release];
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set image and clear temporary data/image
    UIImage *rawImage = [[UIImage alloc] initWithData:self.activeDownload];
    
    /*
    if (rawImage.size.width != NEWS_IMG_WIDTH && rawImage.size.height != NEWS_IMG_HEIGHT) {
        CGSize itemSize = CGSizeMake(NEWS_IMG_WIDTH, NEWS_IMG_HEIGHT);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[rawImage drawInRect:imageRect];
		self.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
    }
    else {
        self.image = rawImage;
    }*/
    
    self.image = rawImage;
    self.activeDownload = nil;
    [rawImage release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our image is ready for display
    [delegate newsImageDidLoad:self.indexPath];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

@end
