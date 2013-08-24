//
//  ProductsParseOperation.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *kProductsErrorNotif;
extern NSString *kProductsMsgErrorKey;

@class Product;

@interface ProductsParseOperation : NSOperation {
    NSData *productsData;
    
@private
    // these variables are used during parsing
    Product *currentProduct;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (copy, readonly) NSData *productsData;

@property (retain) NSManagedObjectContext *managedObjectContext;

@end
