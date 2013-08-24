//
//  PromotesParseOperation.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-7-25.
//  Copyright 2011. All rights reserved.
//

#import "PromotesParseOperation.h"
#import "Promote.h"
#import "Feed.h"
#import "News.h"
#import "NewsReaderAppDelegate.h"


// NSNotification name for reporting errors
NSString *kPromotesErrorNotif = @"PromotesErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kPromotesMsgErrorKey = @"PromotesMsgErrorKey";

@interface PromotesParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) Promote *currentPromote;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

@end

@implementation PromotesParseOperation

@synthesize promotesData, currentPromote, currentParseBatch, currentParsedCharacterData, managedObjectContext;

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {    
        promotesData = [parseData copy];
        
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

- (void)addPromotesToList:(NSArray *)promotes
{
    assert([NSThread isMainThread]);
    
    Promote *promote;
    NSError *error = nil;
    
    NSFetchRequest *promoteFetchRequest = [[NSFetchRequest alloc] init];
    promoteFetchRequest.entity = [NSEntityDescription entityForName:@"Promote"
                                             inManagedObjectContext:self.managedObjectContext];
    promoteFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    
    NSArray *promoteFetchedItems = [self.managedObjectContext executeFetchRequest:promoteFetchRequest error:&error];
    
    NSFetchRequest *feedFetchRequest = [[NSFetchRequest alloc] init];
    feedFetchRequest.entity = [NSEntityDescription entityForName:@"Feed"
                                          inManagedObjectContext:self.managedObjectContext];
    feedFetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    
    NSArray *feedFetchedItems = [self.managedObjectContext executeFetchRequest:feedFetchRequest error:&error];

    NSArray *idsInPromotes = [promotes valueForKey:@"feedid"];
    NSArray *idsInFeeds = [feedFetchedItems valueForKey:@"feedid"];
    
    for (promote in promoteFetchedItems) {
        if (![idsInPromotes containsObject:promote.feedid]) {
            if (![idsInFeeds containsObject:promote.feedid] && [promote.cached boolValue]) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = [NSEntityDescription entityForName:@"News"
                                                  inManagedObjectContext:self.managedObjectContext];
                fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", promote.feedid];

                NSArray *fetchedNews = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                for (News *news in fetchedNews) {
                    [self.managedObjectContext deleteObject:news];
                }
                
                [fetchRequest release];
            }
            [self.managedObjectContext deleteObject:promote];
        }
    }
    
    for (promote in promotes) {
        promoteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", promote.feedid];
        promoteFetchedItems = [self.managedObjectContext executeFetchRequest:promoteFetchRequest error:&error];
        
        feedFetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", promote.feedid];
        feedFetchedItems = [self.managedObjectContext executeFetchRequest:feedFetchRequest error:&error];

        if ([promoteFetchedItems count] == 0) {
            if ([feedFetchedItems count] != 0) {
                Feed *feed = (Feed *)[feedFetchedItems objectAtIndex:0];
                promote.cached = feed.cached;
            }
            [self.managedObjectContext insertObject:promote];
        }
    }
    
    [promoteFetchRequest release];
    [feedFetchRequest release];
    
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
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.promotesData];
    [parser setDelegate:self];
    [parser parse];
    
    // Always perform, even if no promote in currentParseBatch.
    [self performSelectorOnMainThread:@selector(addPromotesToList:)
                           withObject:self.currentParseBatch
                        waitUntilDone:NO];
    
    self.currentPromote = nil;
    self.currentParseBatch = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

- (void)dealloc
{
    [promotesData release];
    
    [dateFormatter release];
    [currentPromote release];
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
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Promote"
                                               inManagedObjectContext:self.managedObjectContext];
        Promote *promote = [[Promote alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];  
        self.currentPromote = promote;
        [promote release];
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
        self.currentPromote.cached = [NSNumber numberWithBool:NO];
        [self.currentParseBatch addObject:self.currentPromote];
    } else if ([elementName isEqualToString:@"id"]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        long long promoteId;
        if ([scanner scanLongLong:&promoteId]) {
            self.currentPromote.feedid = [NSNumber numberWithLongLong:promoteId];
        }
    } else if ([elementName isEqualToString:@"name"]) {
        self.currentPromote.name = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"link"]) {
        self.currentPromote.link = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"pubDate"]) {
        self.currentPromote.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
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

// an error occurred while parsing the promotes data, post the error as an NSNotification.
// 
- (void)handlePromotesError:(NSError *)parseError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPromotesErrorNotif
                                                        object:self
                                                      userInfo:
     [NSDictionary dictionaryWithObject:parseError forKey:kPromotesMsgErrorKey]];
}

// an error occurred while parsing the promotes data, pass the error to the main thread for handling.
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handlePromotesError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
