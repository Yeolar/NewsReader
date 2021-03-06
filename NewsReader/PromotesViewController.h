//
//  PromotesViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-7-25.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmlDownloader.h"


@interface PromotesViewController : UITableViewController <NSFetchedResultsControllerDelegate, XmlDownloaderDelegate> {
@private
    //NSDateFormatter *dateFormatter;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)handleError:(NSError *)error;

@end
