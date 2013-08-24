//
//  ManagerViewController.m
//  NewsReader
//
//  Created by Yeolar <yeolar@gmail.com> on 11-6-16.
//  Copyright 2011. All rights reserved.
//

#import "ManagerViewController.h"
#import "Product.h"
#import "Common.h"


static NSUInteger const kTitleLabelTag = 52;
static NSUInteger const kDescLabelTag = 53;
static NSUInteger const kSubsButtonTag = 54;

@implementation ManagerViewController

@synthesize states, managedObjectContext, fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [states release];
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
    
    self.title = NSLocalizedString(@"Product Manager", @"The title of the product manager view.");
    
    self.states = [NSMutableDictionary dictionary];

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Product"
                                           inManagedObjectContext:managedObjectContext];
    fetchRequest.entity = ent;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"pdid", nil];
    
    NSError *error = nil;
    for (NSNumber *pdid in self.states) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pdid = %@", pdid];
        
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedItems.count != 0) {
            Product *oldProduct = (Product *)[fetchedItems objectAtIndex:0];
            if ([self.states objectForKey:pdid] != oldProduct.subscribed) {
                Product *newProduct = [[Product alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
                newProduct.pdid = oldProduct.pdid;
                newProduct.name = oldProduct.name;
                newProduct.desc = oldProduct.desc;
                newProduct.subscribed = [self.states objectForKey:pdid];
                newProduct.cancelable = oldProduct.cancelable;
                
                [managedObjectContext deleteObject:oldProduct];
                [managedObjectContext insertObject:newProduct];
            }
        }
    }
    
    [fetchRequest release];

    if (![managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    //[self.states removeAllObjects];
    //self.states = [NSMutableDictionary dictionary];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
        UIButton *subsButton = (UIButton *)[cell.contentView viewWithTag:kSubsButtonTag];
        
        UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
        
        UIInterfaceOrientation toOrientation = self.interfaceOrientation;
        if (toOrientation == UIInterfaceOrientationPortrait ||
            toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(APP_WIDTH - SUBS_BTN_WIDTH - 30, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - SUBS_BTN_WIDTH - 30, 20);
            descLabel.frame = CGRectMake(10, 30, APP_WIDTH - SUBS_BTN_WIDTH - 30, descHeight);
            subsButton.frame = CGRectMake(APP_WIDTH - SUBS_BTN_WIDTH - 10, 20, SUBS_BTN_WIDTH, SUBS_BTN_HEIGHT);
        } else {
            CGFloat descHeight = [descLabel.text sizeWithFont:font
                                            constrainedToSize:CGSizeMake(APP_HEIGHT - SUBS_BTN_WIDTH - 30, CGFLOAT_MAX)
                                                lineBreakMode:UILineBreakModeWordWrap].height;
            titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - SUBS_BTN_WIDTH - 30, 20);
            descLabel.frame = CGRectMake(10, 30, APP_HEIGHT - SUBS_BTN_WIDTH - 30, descHeight);
            subsButton.frame = CGRectMake(APP_HEIGHT - SUBS_BTN_WIDTH - 10, 20, SUBS_BTN_WIDTH, SUBS_BTN_HEIGHT);
        }
    }
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
    Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self.states objectForKey:product.pdid] == nil) {
        [self.states setObject:product.subscribed forKey:product.pdid];
    }

    // Declare references to the subviews which will display the feeds.
    UILabel *titleLabel = nil;
    UILabel *descLabel = nil;
    UIButton *subsButton = nil;
    
    static NSString *CellIdentifier = @"ProductAddCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        titleLabel = [[[UILabel alloc] init] autorelease];
        titleLabel.tag = kTitleLabelTag;
        titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FSIZE];
        [cell.contentView addSubview:titleLabel];
        
        descLabel = [[[UILabel alloc] init] autorelease];
        descLabel.tag = kDescLabelTag;
        descLabel.font = [UIFont systemFontOfSize:DESC_FSIZE];
        descLabel.lineBreakMode = UILineBreakModeWordWrap;
        descLabel.numberOfLines = 0;
        [cell.contentView addSubview:descLabel];
        
        subsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        subsButton.tag = kSubsButtonTag;
        subsButton.titleLabel.font = [UIFont systemFontOfSize:BUTTON_FSIZE];
        [subsButton addTarget:self action:@selector(setButtonDownColor:) forControlEvents:UIControlEventTouchDown];
        [subsButton addTarget:self action:@selector(AddAndCancelFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:subsButton];
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews using their tags.
        titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
        descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
        subsButton = (UIButton *)[cell.contentView viewWithTag:kSubsButtonTag];
    }
    
    titleLabel.text = product.name;
    descLabel.text = product.desc;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:kTitleLabelTag];
    UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:kDescLabelTag];
    UIButton *subsButton = (UIButton *)[cell.contentView viewWithTag:kSubsButtonTag];

    UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];

    UIInterfaceOrientation toOrientation = self.interfaceOrientation;
    if (toOrientation == UIInterfaceOrientationPortrait || toOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGFloat descHeight = [descLabel.text sizeWithFont:font
                                        constrainedToSize:CGSizeMake(APP_WIDTH - SUBS_BTN_WIDTH - 30, CGFLOAT_MAX)
                                            lineBreakMode:UILineBreakModeWordWrap].height;
        titleLabel.frame = CGRectMake(10, 5, APP_WIDTH - SUBS_BTN_WIDTH - 30, 20);
        descLabel.frame = CGRectMake(10, 30, APP_WIDTH - SUBS_BTN_WIDTH - 30, descHeight);
        subsButton.frame = CGRectMake(APP_WIDTH - SUBS_BTN_WIDTH - 10, 20, SUBS_BTN_WIDTH, SUBS_BTN_HEIGHT);
    } else {
        CGFloat descHeight = [descLabel.text sizeWithFont:font
                                        constrainedToSize:CGSizeMake(APP_HEIGHT - SUBS_BTN_WIDTH - 30, CGFLOAT_MAX)
                                            lineBreakMode:UILineBreakModeWordWrap].height;
        titleLabel.frame = CGRectMake(10, 5, APP_HEIGHT - SUBS_BTN_WIDTH - 30, 20);
        descLabel.frame = CGRectMake(10, 30, APP_HEIGHT - SUBS_BTN_WIDTH - 30, descHeight);
        subsButton.frame = CGRectMake(APP_HEIGHT - SUBS_BTN_WIDTH - 10, 20, SUBS_BTN_WIDTH, SUBS_BTN_HEIGHT);
    }
    
    subsButton.layer.masksToBounds = YES;
    subsButton.layer.cornerRadius = 6.0;
    subsButton.layer.borderWidth = 1.0;
    subsButton.layer.borderColor = [SUBS_BUTTON_BGCOLOR_B CGColor];
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.bounds = subsButton.bounds;
    gradientLayer.position = CGPointMake(subsButton.bounds.size.width / 2, subsButton.bounds.size.height / 2);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[SUBS_BUTTON_BGCOLOR_L CGColor], (id)[SUBS_BUTTON_BGCOLOR CGColor], nil];
    [subsButton.layer insertSublayer:gradientLayer atIndex:0];
    [gradientLayer release];

    Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configProductState:[[self.states objectForKey:product.pdid] boolValue] atCell:cell];

    if (![product.cancelable boolValue]) {
        subsButton.hidden = YES;
    } else {
        subsButton.hidden = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
    UIFont *font = [UIFont systemFontOfSize:DESC_FSIZE];
    CGFloat descHeight = [product.desc sizeWithFont:font
                                  constrainedToSize:CGSizeMake(APP_WIDTH - SUBS_BTN_WIDTH - 30, CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap].height;
    return (descHeight > SUBS_BTN_HEIGHT - 10) ? (descHeight + 37) : SUBS_BTN_HEIGHT + 27;
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

- (void)configProductState:(BOOL)state atCell:(UITableViewCell *)cell
{
    UIButton *subsButton = (UIButton *)[cell.contentView viewWithTag:kSubsButtonTag];
    
    if (state) {
        [subsButton setTitle:NSLocalizedString(@"Remove", @"The title of the unsubscribe button.")
                    forState:UIControlStateNormal];
    } else {
        [subsButton setTitle:NSLocalizedString(@"Add", @"The title of the subscribe button.")
                    forState:UIControlStateNormal];
    }
}

- (IBAction)setButtonDownColor:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[button.layer.sublayers objectAtIndex:0];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[SUBS_BUTTON_BGCOLOR CGColor], (id)[[UIColor blackColor] CGColor], nil];
    [button.layer needsDisplay];
}

- (IBAction)AddAndCancelFeed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    CAGradientLayer *gradientLayer = (CAGradientLayer *)[button.layer.sublayers objectAtIndex:0];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[SUBS_BUTTON_BGCOLOR_L CGColor], (id)[SUBS_BUTTON_BGCOLOR CGColor], nil];
    [button.layer needsDisplay];

    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;

    BOOL state = (button.titleLabel.text == NSLocalizedString(@"Add", nil)) ? YES : NO;
    
    [self configProductState:state atCell:cell];
    
    Product *product = (Product *)[fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    [self.states setObject:[NSNumber numberWithBool:state] forKey:product.pdid];
}

#pragma mark -
#pragma mark Core Data

- (NSFetchedResultsController *)fetchedResultsController
{
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pdid" ascending:YES];
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
