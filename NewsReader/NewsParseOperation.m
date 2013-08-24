//
//  NewsParseOperation.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright 2011. All rights reserved.
//

#import "NewsParseOperation.h"
#import "News.h"
#import "Feed.h"
#import "Promote.h"
#import "NewsReaderAppDelegate.h"


// NSNotification name for sending news data
NSString *kAddNewsNotif = @"AddNewsNotif";

// NSNotification userInfo key for obtaining the news data
NSString *kNewsResultsKey = @"NewsResultsKey";

// NSNotification name for reporting errors
NSString *kNewsErrorNotif = @"NewsErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kNewsMsgErrorKey = @"NewsMsgErrorKey";

@interface NewsParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) NewsObject *currentNews;
@property (nonatomic, retain) NSMutableString *currentChannel;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

@end

@implementation NewsParseOperation

@synthesize newsData, currentNews, currentChannel, currentParseBatch, currentParsedCharacterData, managedObjectContext;

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {    
        newsData = [parseData copy];
        
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

- (void)addNewsToList:(NSArray *)newsArray
{
    assert([NSThread isMainThread]);
    
    NSEntityDescription *ent;
    NSError *error = nil;

    NSFetchRequest *feedFetchRequest = [[NSFetchRequest alloc] init];
    ent = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
    feedFetchRequest.entity = ent;
    feedFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    feedFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", [NSNumber numberWithLongLong:feedId]];
    
    NSArray *feedFetchedItems = [self.managedObjectContext executeFetchRequest:feedFetchRequest error:&error];

    NSFetchRequest *promoteFetchRequest = [[NSFetchRequest alloc] init];
    ent = [NSEntityDescription entityForName:@"Promote" inManagedObjectContext:self.managedObjectContext];
    promoteFetchRequest.entity = ent;
    promoteFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    promoteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", [NSNumber numberWithLongLong:feedId]];
    
    NSArray *promoteFetchedItems = [self.managedObjectContext executeFetchRequest:promoteFetchRequest error:&error];

    NSFetchRequest *newsFetchRequest = [[NSFetchRequest alloc] init];
    ent = [NSEntityDescription entityForName:@"News" inManagedObjectContext:self.managedObjectContext];
    newsFetchRequest.entity = ent;
    newsFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    newsFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", [NSNumber numberWithLongLong:feedId]];
    
    NSArray *newsFetchedItems = [self.managedObjectContext executeFetchRequest:newsFetchRequest error:&error];

    [feedFetchRequest release];
    [promoteFetchRequest release];
    [newsFetchRequest release];

    if ((([feedFetchedItems count] != 0) || ([promoteFetchedItems count] != 0)) && ([newsFetchedItems count] == 0)) {
        for (NewsObject *newsObject in newsArray) {
            News *news = [[News alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
            
            news.title   = [newsObject.title copy];
            news.date    = [newsObject.date copy];
            news.link    = [newsObject.link copy];
            news.desc    = [newsObject.desc copy];
            news.imgurl  = [newsObject.imgurl copy];
            news.feedid  = [NSNumber numberWithLongLong:feedId];
            news.channel = [newsObject.channel copy];
            news.type    = [newsObject.type copy];
            
            [self.managedObjectContext insertObject:news];
        }

        if ([feedFetchedItems count] != 0) {
            Feed *oldFeed = (Feed *)[feedFetchedItems objectAtIndex:0];
            
            ent = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:managedObjectContext];
            Feed *feed = [[Feed alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
            feed.feedid = oldFeed.feedid;
            feed.name = [oldFeed.name copy];
            feed.link = [oldFeed.link copy];
            feed.date = [oldFeed.date copy];
            feed.cached = [NSNumber numberWithBool:YES];
            
            [self.managedObjectContext deleteObject:oldFeed];
            [self.managedObjectContext insertObject:feed];
        }

        if ([promoteFetchedItems count] != 0) {
            Promote *oldPromote = (Promote *)[promoteFetchedItems objectAtIndex:0];
            
            ent = [NSEntityDescription entityForName:@"Promote" inManagedObjectContext:managedObjectContext];
            Promote *promote = [[Promote alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
            promote.feedid = oldPromote.feedid;
            promote.name = [oldPromote.name copy];
            promote.link = [oldPromote.link copy];
            promote.date = [oldPromote.date copy];
            promote.cached = [NSNumber numberWithBool:YES];
            
            [self.managedObjectContext deleteObject:oldPromote];
            [self.managedObjectContext insertObject:promote];
        }

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddNewsNotif
                                                        object:self
                                                      userInfo:
     [NSDictionary dictionaryWithObject:newsArray forKey:kNewsResultsKey]];
}

// the main function for this NSOperation, to start the parsing
- (void)main
{
    self.currentChannel = [NSMutableString string];
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];

    accumulatingParsedItem = NO;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.newsData];
    [parser setDelegate:self];
    [parser parse];
    
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addNewsToList:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
    }
    
    self.currentNews = nil;
    self.currentChannel = nil;
    self.currentParseBatch = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

- (void)dealloc
{
    [newsData release];
    
    [dateFormatter release];
    [currentNews release];
    [currentChannel release];
    [currentParseBatch release];
    [currentParsedCharacterData release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"channel"]) {
        [currentChannel setString:@""];
    } else if ([elementName isEqualToString:@"item"]) {
        NewsObject *news = [[NewsObject alloc] init];  
        self.currentNews = news;
        [news release];
        accumulatingParsedItem = YES;
        NSString *typeAttribute = [attributeDict valueForKey:@"type"];
        if (typeAttribute) {
            self.currentNews.type = typeAttribute;
        } else {
            self.currentNews.type = @"normal";
        }
    } else if ([elementName isEqualToString:@"newspaperid"] ||
               [elementName isEqualToString:@"title"] ||
               [elementName isEqualToString:@"link"] ||
               [elementName isEqualToString:@"pubDate"] ||
               [elementName isEqualToString:@"description"] ||
               [elementName isEqualToString:@"picurl"]) {
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{     
    if ([elementName isEqualToString:@"newspaperid"]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        [scanner scanLongLong:&feedId];
    } else if ([elementName isEqualToString:@"item"]) {
        self.currentNews.feedid = [NSNumber numberWithLongLong:feedId];
        self.currentNews.channel = [self.currentChannel copy];
        [self.currentParseBatch addObject:self.currentNews];
        accumulatingParsedItem = NO;
    } else if ([elementName isEqualToString:@"title"]) {
        if (accumulatingParsedItem) {
            self.currentNews.title = [self.currentParsedCharacterData copy];
        } else {
            self.currentChannel = [self.currentParsedCharacterData mutableCopy];
        }
    } else if ([elementName isEqualToString:@"link"]) {
        if (accumulatingParsedItem) {
            self.currentNews.link = [self.currentParsedCharacterData copy];
        }
    } else if ([elementName isEqualToString:@"pubDate"]) {
        if (accumulatingParsedItem) {
            self.currentNews.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
        }
    } else if ([elementName isEqualToString:@"description"]) {
        if (accumulatingParsedItem) {
            self.currentNews.desc = [self.currentParsedCharacterData copy];
        }
    } else if ([elementName isEqualToString:@"picurl"]) {
        if (accumulatingParsedItem) {
            self.currentNews.imgurl = [self.currentParsedCharacterData copy];
        }
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

// an error occurred while parsing the news data, post the error as an NSNotifications.
// 
- (void)handleNewsError:(NSError *)parseError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsErrorNotif
                                                        object:self
                                                      userInfo:
     [NSDictionary dictionaryWithObject:parseError forKey:kNewsMsgErrorKey]];
}

// an error occurred while parsing the news data, pass the error to the main thread for handling.
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleNewsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
