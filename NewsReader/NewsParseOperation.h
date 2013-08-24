//
//  NewsParseOperation.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *kAddNewsNotif;
extern NSString *kNewsResultsKey;

extern NSString *kNewsErrorNotif;
extern NSString *kNewsMsgErrorKey;

@class NewsObject;

@interface NewsParseOperation : NSOperation {
    NSData *newsData;
    
@private
    NSDateFormatter *dateFormatter;
    
    // these variables are used during parsing
    long long feedId;
    NewsObject *currentNews;
    NSMutableString *currentChannel;
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    BOOL accumulatingParsedItem;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (copy, readonly) NSData *newsData;

@property (retain) NSManagedObjectContext *managedObjectContext;

@end
