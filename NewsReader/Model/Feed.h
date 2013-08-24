//
//  Feed.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject {
}

@property (nonatomic, assign) NSNumber *feedid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) NSNumber *cached;

@end
