//
//  News.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-18.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NewsObject : NSObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *imgurl;
@property (nonatomic, assign) NSNumber *feedid;
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) NSString *type;

@end

@interface News : NSManagedObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *imgurl;
@property (nonatomic, assign) NSNumber *feedid;
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) NSString *type;

@end
