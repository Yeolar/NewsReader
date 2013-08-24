//
//  ManagerViewController.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ManagerViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
@private
    NSMutableDictionary *states;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSMutableDictionary *states;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)configProductState:(BOOL)state atCell:(UITableViewCell *)cell;
- (IBAction)setButtonDownColor:(id)sender;
- (IBAction)AddAndCancelFeed:(id)sender;

@end
