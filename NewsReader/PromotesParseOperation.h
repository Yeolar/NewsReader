//
//  PromotesParseOperation.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-7-25.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *kPromotesErrorNotif;
extern NSString *kPromotesMsgErrorKey;

@class Promote;

@interface PromotesParseOperation : NSOperation {
    NSData *promotesData;
    
@private
    NSDateFormatter *dateFormatter;

    // these variables are used during parsing
    Promote *currentPromote;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (copy, readonly) NSData *promotesData;

@property (retain) NSManagedObjectContext *managedObjectContext;

@end
