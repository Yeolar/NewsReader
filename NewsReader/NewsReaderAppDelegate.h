//
//  NewsReaderAppDelegate.h
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-15.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RootViewController, NewsViewController, FeedsViewController, PromotesViewController, ManagerViewController;
@class HelpViewController, DetailViewController, HelpDetailViewController;

@interface NewsReaderAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navigationController;
    RootViewController *rootViewController;
    NewsViewController *newsViewController;
    FeedsViewController *feedsViewController;
    PromotesViewController *promotesViewController;
    ManagerViewController *managerViewController;
    HelpViewController *helpViewController;
    DetailViewController *detailViewController;
    HelpDetailViewController *helpDetailViewController;

    NSOperationQueue *parseQueue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet NewsViewController *newsViewController;
@property (nonatomic, retain) IBOutlet FeedsViewController *feedsViewController;
@property (nonatomic, retain) IBOutlet PromotesViewController *promotesViewController;
@property (nonatomic, retain) IBOutlet ManagerViewController *managerViewController;
@property (nonatomic, retain) IBOutlet HelpViewController *helpViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet HelpDetailViewController *helpDetailViewController;

@property (nonatomic, retain) NSOperationQueue *parseQueue;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)fetchAppSettings;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
