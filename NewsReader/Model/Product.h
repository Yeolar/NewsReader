//
//  Product.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright (c) 2011. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject {
}

@property (nonatomic, assign) NSNumber *pdid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) NSNumber *subscribed;
@property (nonatomic, assign) NSNumber *cancelable;

@end
