//
//  FeedsParseOperation.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright 2011. All rights reserved.
//

#import "FeedsParseOperation.h"
#import "Feed.h"
#import "Promote.h"
#import "News.h"
#import "NewsReaderAppDelegate.h"


// NSNotification name for reporting errors
NSString *kFeedsErrorNotif = @"FeedsErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kFeedsMsgErrorKey = @"FeedsMsgErrorKey";

@interface FeedsParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) Feed *currentFeed;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

@end

@implementation FeedsParseOperation

@synthesize feedsData, currentFeed, currentParseBatch, currentParsedCharacterData, managedObjectContext;

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {    
        feedsData = [parseData copy];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
        
        // setup our Core Data scratch pad and persistent store
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setUndoManager:nil];
        
        NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.managedObjectContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    }
    return self;
}

- (void)addFeedsToList:(NSArray *)feeds
{
    assert([NSThread isMainThread]);
    
    Feed *feed;
    NSError *error = nil;
    
    NSFetchRequest *feedFetchRequest = [[NSFetchRequest alloc] init];
    feedFetchRequest.entity = [NSEntityDescription entityForName:@"Feed"
                                          inManagedObjectContext:self.managedObjectContext];
    feedFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    
    NSArray *feedFetchedItems = [self.managedObjectContext executeFetchRequest:feedFetchRequest error:&error];
    
    NSFetchRequest *promoteFetchRequest = [[NSFetchRequest alloc] init];
    promoteFetchRequest.entity = [NSEntityDescription entityForName:@"Promote"
                                             inManagedObjectContext:self.managedObjectContext];
    promoteFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    
    NSArray *promoteFetchedItems = [self.managedObjectContext executeFetchRequest:promoteFetchRequest error:&error];
    
    NSArray *idsInFeeds = [feeds valueForKey:@"feedid"];
    NSArray *idsInPromotes = [promoteFetchedItems valueForKey:@"feedid"];
    
    for (feed in feedFetchedItems) {
        if (![idsInFeeds containsObject:feed.feedid]) {
            if (![idsInPromotes containsObject:feed.feedid] && [feed.cached boolValue]) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = [NSEntityDescription entityForName:@"News"
                                                  inManagedObjectContext:self.managedObjectContext];
                fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", feed.feedid];

                NSArray *fetchedNews = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                for (News *news in fetchedNews) {
                    [self.managedObjectContext deleteObject:news];
                }
                
                [fetchRequest release];
            }
            [self.managedObjectContext deleteObject:feed];
        }
    }
    
    for (feed in feeds) {
        feedFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", feed.feedid];
        feedFetchedItems = [self.managedObjectContext executeFetchRequest:feedFetchRequest error:&error];

        promoteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", feed.feedid];
        promoteFetchedItems = [self.managedObjectContext executeFetchRequest:promoteFetchRequest error:&error];

        if ([feedFetchedItems count] == 0) {
            if ([promoteFetchedItems count] != 0) {
                Promote *promote = (Promote *)[promoteFetchedItems objectAtIndex:0];
                feed.cached = promote.cached;
            }
            [self.managedObjectContext insertObject:feed];
        }
    }
    
    [feedFetchRequest release];
    [promoteFetchRequest release];
    
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
}

// the main function for this NSOperation, to start the parsing
- (void)main
{
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.feedsData];
    [parser setDelegate:self];
    [parser parse];
    
    // Always perform, even if no feed in currentParseBatch.
    [self performSelectorOnMainThread:@selector(addFeedsToList:)
                           withObject:self.currentParseBatch
                        waitUntilDone:NO];
    
    self.currentFeed = nil;
    self.currentParseBatch = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

- (void)dealloc
{
    [feedsData release];
    
    [dateFormatter release];
    [currentFeed release];
    [currentParseBatch release];
    [currentParsedCharacterData release];
    
    [managedObjectContext release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"newspaper"]) {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Feed"
                                               inManagedObjectContext:self.managedObjectContext];
        Feed *feed = [[Feed alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];  
        self.currentFeed = feed;
        [feed release];
    } else if ([elementName isEqualToString:@"id"] ||
               [elementName isEqualToString:@"name"] ||
               [elementName isEqualToString:@"link"] ||
               [elementName isEqualToString:@"pubDate"]) {
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{     
    if ([elementName isEqualToString:@"newspaper"]) {
        self.currentFeed.cached = [NSNumber numberWithBool:NO];
        [self.currentParseBatch addObject:self.currentFeed];
    } else if ([elementName isEqualToString:@"id"]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        long long feedId;
        if ([scanner scanLongLong:&feedId]) {
            self.currentFeed.feedid = [NSNumber numberWithLongLong:feedId];
        }
    } else if ([elementName isEqualToString:@"name"]) {
        self.currentFeed.name = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"link"]) {
        self.currentFeed.link = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"pubDate"]) {
        self.currentFeed.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the feeds data, post the error as an NSNotification.
// 
- (void)handleFeedsError:(NSError *)parseError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFeedsErrorNotif
                                                        object:self
                                                      userInfo:
     [NSDictionary dictionaryWithObject:parseError forKey:kFeedsMsgErrorKey]];
}

// an error occurred while parsing the feeds data, pass the error to the main thread for handling.
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleFeedsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
