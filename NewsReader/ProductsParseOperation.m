//
//  ProductsParseOperation.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import "ProductsParseOperation.h"
#import "Product.h"
#import "NewsReaderAppDelegate.h"


// NSNotification name for reporting errors
NSString *kProductsErrorNotif = @"ProductsErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kProductsMsgErrorKey = @"ProductsMsgErrorKey";

@interface ProductsParseOperation () <NSXMLParserDelegate>

@property (nonatomic, retain) Product *currentProduct;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

@end

@implementation ProductsParseOperation

@synthesize productsData, currentProduct, currentParseBatch, currentParsedCharacterData, managedObjectContext;

- (id)initWithData:(NSData *)parseData
{
    self = [super init];
    if (self) {    
        productsData = [parseData copy];
        
        // setup our Core Data scratch pad and persistent store
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setUndoManager:nil];
        
        NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.managedObjectContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
    }
    return self;
}

- (void)addProductsToList:(NSArray *)products
{
    assert([NSThread isMainThread]);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Product"
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"pdid", nil];

    NSError *error = nil;
    Product *product = nil;
    for (product in products) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pdid = %@", product.pdid];
        
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedItems.count != 0) {
            product.subscribed = ((Product *)[fetchedItems objectAtIndex:0]).subscribed;
            if (![product.cancelable boolValue]) {
                product.subscribed = [NSNumber numberWithBool:YES];
            }
        }
    }
    
    fetchRequest.predicate = nil;
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (product in fetchedItems) {
        [self.managedObjectContext deleteObject:product];
    }
    
    for (product in products) {
        [self.managedObjectContext insertObject:product];
    }
    
    [fetchRequest release];
    
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
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.productsData];
    [parser setDelegate:self];
    [parser parse];
    
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addProductsToList:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
    }
    
    self.currentProduct = nil;
    self.currentParseBatch = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

- (void)dealloc
{
    [productsData release];
    
    [currentProduct release];
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
    if ([elementName isEqualToString:@"product"]) {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Product"
                                               inManagedObjectContext:self.managedObjectContext];
        Product *product = [[Product alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];  
        self.currentProduct = product;
        [product release];
    } else if ([elementName isEqualToString:@"id"] ||
               [elementName isEqualToString:@"name"] ||
               [elementName isEqualToString:@"isCancelable"]) {
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    } else if ([elementName isEqualToString:@"description"]) {
        [currentParsedCharacterData setString:@""];
    } else if ([elementName isEqualToString:@"para"]) {
        accumulatingParsedCharacterData = YES;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{     
    if ([elementName isEqualToString:@"product"]) {
        self.currentProduct.subscribed = [NSNumber numberWithBool:YES];
        [self.currentParseBatch addObject:self.currentProduct];
    } else if ([elementName isEqualToString:@"id"]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        long long productId;
        if ([scanner scanLongLong:&productId]) {
            self.currentProduct.pdid = [NSNumber numberWithLongLong:productId];
        }
    } else if ([elementName isEqualToString:@"name"]) {
        self.currentProduct.name = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"isCancelable"]) {
        self.currentProduct.cancelable = [NSNumber numberWithBool:YES];
        if ([self.currentParsedCharacterData isEqualToString:@"0"]) {
            self.currentProduct.cancelable = [NSNumber numberWithBool:NO];
        }
    } else if ([elementName isEqualToString:@"description"]) {
        [self.currentParsedCharacterData deleteCharactersInRange:
         NSMakeRange([self.currentParsedCharacterData length] - 1, 1)];
        self.currentProduct.desc = [self.currentParsedCharacterData copy];
    } else if ([elementName isEqualToString:@"para"]) {
        [self.currentParsedCharacterData appendString:@"\n"];
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

// an error occurred while parsing the products data, post the error as an NSNotification.
// 
- (void)handleProductsError:(NSError *)parseError
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsErrorNotif
                                                        object:self
                                                      userInfo:
     [NSDictionary dictionaryWithObject:parseError forKey:kProductsMsgErrorKey]];
}

// an error occurred while parsing the products data, pass the error to the main thread for handling.
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleProductsError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
