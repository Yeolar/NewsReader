//
//  FeedsParseOperation.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *kFeedsErrorNotif;
extern NSString *kFeedsMsgErrorKey;

@class Feed;

@interface FeedsParseOperation : NSOperation {
    NSData *feedsData;
    
@private
    NSDateFormatter *dateFormatter;

    // these variables are used during parsing
    Feed *currentFeed;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (copy, readonly) NSData *feedsData;

@property (retain) NSManagedObjectContext *managedObjectContext;

@end
