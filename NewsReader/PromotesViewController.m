//
//  PromotesViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-7-25.
//  Copyright 2011. All rights reserved.
//

#import "PromotesViewController.h"
#import "NewsViewController.h"
#import "Promote.h"
#import "NewsParseOperation.h"
#import "NewsReaderAppDelegate.h"
#import "Common.h"


@implementation PromotesViewController

@synthesize managedObjectContext, fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"MM'-'dd' 'HH':'mm"];
    }
    return self;
}

- (void)dealloc
{
    //[dateFormatter release];
    [managedObjectContext release];
    [fetchedResultsController release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Promote List", @"The title of the promote list view.");
    
    self.tableView.rowHeight = 40;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PromoteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Promote *promote = (Promote *)[fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [[[NSString alloc] initWithFormat:@"%@", promote.name] autorelease];
    cell.textLabel.font = [UIFont systemFontOfSize:TITLE_FSIZE];
    if ([promote.cached boolValue]) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];

    appDelegate.newsViewController.haveHeadlines = NO;
    
    appDelegate.newsViewController.loadingView.hidden = NO;
    //[appDelegate.newsViewController.view bringSubviewToFront:appDelegate.newsViewController.loadingView];
    [appDelegate.newsViewController.activityInicatorView startAnimating];

    appDelegate.newsViewController.newspaper = [NSMutableArray array];
    [appDelegate.newsViewController.tableView reloadData];

    Promote *promote = (Promote *)[fetchedResultsController objectAtIndexPath:indexPath];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"News"
                                           inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"feedid", nil];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"feedid = %@", promote.feedid];
    
    NSError *error = nil;
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedItems count] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddNewsNotif
                                                            object:self
                                                          userInfo:
         [NSDictionary dictionaryWithObject:fetchedItems forKey:kNewsResultsKey]];
    } else {
        XmlDownloader *xmlDownloader = [[XmlDownloader alloc] init];
        xmlDownloader.parserTag = 2;
        xmlDownloader.xmlURLString = promote.link;
        xmlDownloader.delegate = self;
        [xmlDownloader startDownload];
        [xmlDownloader release];
    }
    
    [fetchRequest release];

    [self.navigationController pushViewController:appDelegate.newsViewController animated:YES];
}

- (void)xmlDidDownload:(NSMutableData *)data withParserTag:(NSUInteger)parserTag
{    
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    NewsParseOperation *parseOperation = [[NewsParseOperation alloc] initWithData:data];
    [appDelegate.parseQueue addOperation:parseOperation];
    [parseOperation release];
    
    // NewsParseOperation also modified Promote entity, merge changes and reload data.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:parseOperation.managedObjectContext];
}

- (void)xmlDownloadError:(NSError *)error withParserTag:(NSUInteger)parserTag
{
    NewsReaderAppDelegate *appDelegate = (NewsReaderAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.newsViewController.activityInicatorView stopAnimating];
    [self handleError:error];
}

// Handle errors by showing an alert to the user.
//
- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:
                              NSLocalizedString(@"Error Title",
                                                @"Title for alert displayed when download or parse error occurs.")
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark -
#pragma mark Core Data

- (NSFetchedResultsController *)fetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Promote"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	return fetchedResultsController;
}

// this is called from mergeChanges: method, requested to be made on the main thread
//
- (void)updateContext:(NSNotification *)notif
{
	NSManagedObjectContext *mainContext = [self managedObjectContext];
	[mainContext mergeChangesFromContextDidSaveNotification:notif];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
	[self.tableView reloadData];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our ParseOperation
- (void)mergeChanges:(NSNotification *)notif
{
	NSManagedObjectContext *mainContext = [self managedObjectContext];
    if ([notif object] == mainContext) {
        // main context save, no need to perform the merge
        return;
    }
    [self performSelectorOnMainThread:@selector(updateContext:) withObject:notif waitUntilDone:YES];
}

@end
