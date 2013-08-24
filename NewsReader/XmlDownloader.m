//
//  XmlDownloader.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import "XmlDownloader.h"

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>


@implementation XmlDownloader

@synthesize parserTag, xmlURLString, xmlConnection, xmlData, delegate;

- (void)startDownload
{
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:[NSURL URLWithString:xmlURLString]] delegate:self];
    self.xmlConnection = conn;
    [conn release];
    
    NSAssert(self.xmlConnection != nil, @"Failure to create URL connection.");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // start loading ...
}

- (void)cancelDownload
{
    [self.xmlConnection cancel];
    self.xmlConnection = nil;
    self.xmlData = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dealloc
{
    [xmlURLString release];
    [xmlConnection cancel];
    [xmlConnection release];
    [xmlData release];
    
    [super dealloc];
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
        self.xmlData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [delegate xmlDownloadError:error withParserTag:self.parserTag];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [xmlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // stop loading ...

    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"No Connection Error",
                                                    @"Error message displayed when not connected to the Internet.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [delegate xmlDownloadError:noConnectionError withParserTag:self.parserTag];
    } else {
        // otherwise handle the error generically
        [delegate xmlDownloadError:error withParserTag:self.parserTag];
    }
    self.xmlConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.xmlConnection = nil;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // stop loading ...
    
    if ([self.xmlData length] > 0) {
        [delegate xmlDidDownload:self.xmlData withParserTag:self.parserTag];
    }
    
    // xmlData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.xmlData = nil;
}

@end
