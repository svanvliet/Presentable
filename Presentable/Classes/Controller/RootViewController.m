//
//  RootViewController.m
//  Presentable
//
//  Created by Scott Van Vliet on 5/6/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import "RootViewController.h"
#import "Document.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "DocumentUITableViewCell.h"
#import <QuartzCore/CALayer.h>
#import <CoreGraphics/CGGeometry.h>

@interface RootViewController
(
)
    //
    // Instance method declarations for this application

    - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
    - (void)uploadFailed:(ASIHTTPRequest *)request;
    - (void)uploadFinished:(ASIHTTPRequest *)request;

@end

@implementation RootViewController

    //
    // Property impelementations 

    @synthesize fetchedResultsController=__fetchedResultsController;
    @synthesize managedObjectContext=__managedObjectContext;
    @synthesize requestQueue;
    @synthesize documentCell;

    //
    // Applicaiton startup methods

    // METHOD:  application: viewDidLoad:
    // 
    - (void)viewDidLoad
    {
        [super viewDidLoad];
                
        // Set the Page title
        self.navigationItem.title = @"Conversion Queue";
        
        // Set up the edit and add buttons.
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
        self.navigationItem.rightBarButtonItem = addButton;
        [addButton release];
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
        // Setup UITableView sections    
        
        requestQueue = [[ASINetworkQueue alloc] init];
        [requestQueue setUploadProgressDelegate:progressView];
        [requestQueue setDownloadProgressDelegate:progressView];
        [requestQueue setDelegate: self];
        [requestQueue setRequestDidFailSelector:@selector(uploadFailed:)];
        [requestQueue setRequestDidFinishSelector:@selector(uploadFinished:)];
    }

    //
    // Standard UI behavior methods

    // METHOD:  shouldAutorotateToInterfaceOrientation:
    // 
    -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
    {
        return YES;
    }

    //
    // UITableView delegated methods

    // METHOD:  numberOfSectionsInTableView:
    // 
    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        return [[self.fetchedResultsController sections] count];
    }

    // METHOD:  tableView: numberOfRowsInSection:
    // 
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }

    // METHOD:  tableView: titleForHeaderInSection:
    // 
    -(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        int conversionState = [[sectionInfo name] intValue];
        return [Document documentConversionStateTypeString: conversionState]; // Should be a localized value
    }

    /*
    // METHOD:  tableView: viewForHeaderInSection:
    // 
    - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
    {
        return [[UILabel alloc] init];
    }
    */

    // METHOD:  tableView: willDisplayCell:
    // 
    -(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
    {
        // We can customize the cell prior to it's display here.
    }

    // METHOD:  tableView: cellForRowAtIndexPath:
    // 
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *CellIdentifier = @"Cell"; // Must match Xcode Identifier value for this view
        DocumentUITableViewCell *cell = (DocumentUITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) 
        {
            [[NSBundle mainBundle] loadNibNamed:@"DocumentUITableViewCell" owner:self options:NULL];
            cell = documentCell;
            documentCell = nil;
        }

        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }

    // METHOD:  tableVIew: canMoveRowAtIndexPath:
    //
    - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return NO; // The table view should not be re-orderable.
    }

    // METHOD:  tableView: didSelectRowAtIndexPath:
    //
    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        UIDocumentInteractionController *documentController = nil;
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Document *document = (Document*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        switch ([document.conversionState intValue]) 
        {
            case PENDING:
                
                document.conversionState = [NSNumber numberWithInt:ACTIVE];
                [context save:nil];
                
                [ASIHTTPRequest setDefaultTimeOutSeconds: 60];
                
                ASIFormDataRequest *uploadRequest = [ASIFormDataRequest 
                                                     requestWithURL: [NSURL URLWithString:@"http://dev.cloud.tenseventynine.com/PresentableServices/ConvertDocument"]];
                
                [uploadRequest setPostValue:indexPath forKey:@"documentIndexPath"];
                [uploadRequest setPostValue:[[document objectID] URIRepresentation] forKey:@"documentID"];
                [uploadRequest setFile:[[document originalFileURL] path] forKey:@"document"];
                
                [requestQueue addOperation: uploadRequest];
                [requestQueue go];
                
                #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
                [uploadRequest setShouldContinueWhenAppEntersBackground:YES];
                #endif
                break;
                
            case COMPLETED:
                
                documentController = [UIDocumentInteractionController interactionControllerWithURL:document.convertedFileURL];
                documentController.delegate = self;
                [documentController presentPreviewAnimated:YES];
                
                break;
                
            default:
                break;
        }
    }

    // METHOD:  tableView: commitEditingStyle:
    // 
    - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            NSError *error = nil;
            if (![context save:&error])
            {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }   
    }

    //
    // HTTP request handling methods

    // METHOD:  uploadFailed:
    // 
    -(void)uploadFailed:(ASIHTTPRequest *)request
    {
    }

    // METHOD:  uploadFinished:
    //
    -(void)uploadFinished:(ASIHTTPRequest *)request
    {       
        NSString *documentID = nil;
        for (NSString *header in [request responseHeaders]) { 
            if ([[header lowercaseString] isEqualToString:@"documentid"]) { 
                documentID = [[request responseHeaders] objectForKey:header]; 
            } 
        } 
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSManagedObjectID *documentObjectID = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation: [NSURL URLWithString: documentID]];
        
        Document *document = (Document*)[context objectWithID: documentObjectID];
        
        document.convertedFileType = @"pdf";
        
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", document.fileName, document.convertedFileType]];
        [[request responseData] writeToFile:path atomically:NO];
        
        NSDictionary *documentFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: path error: nil]; // TODO: Implement exception handling
        
        document.convertedFileSizeInBytes = [documentFileAttributes objectForKey: NSFileSize];
        document.convertedFileName = [path lastPathComponent];
        document.conversionCompletedTimeStamp = [NSDate date];
        document.convertedFileURL = [NSURL fileURLWithPath: path];
        document.conversionState = [NSNumber numberWithInt: COMPLETED];
        
        
        [context save: nil]; // TODO: Implement exception handling
        
        progressView.progress = 0.0; // TODO: Put this in a resetProgressIndicators method
        
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Finished" message:path delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView autorelease];
        [alertView show];
        */
        
        
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Finished" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView autorelease];
        [alertView show];
        */
    }

    -(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
    {
        return self.tableView;
    }

    -(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
    {
        return self;
    }

    - (void)didReceiveMemoryWarning
    {
        // Releases the view if it doesn't have a superview.
        [super didReceiveMemoryWarning];
        
        // Relinquish ownership any cached data, images, etc that aren't in use.
    }

    - (void)viewDidUnload
    {
        [progressView release];
        progressView = nil;
        [super viewDidUnload];

        // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
        // For example: self.myOutlet = nil;
    }

    - (void)dealloc
    {
        [__fetchedResultsController release];
        [__managedObjectContext release];
        [progressView release];
        [requestQueue release];
        [super dealloc];
    }

    - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
    {
        Document *document = (Document*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        /*
        NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setCurrencySymbol: @""];
        [formatter setMaximumFractionDigits: 0];
        
        NSNumber *fileSizeInBytes = [[managedObject valueForKey:@"fileSizeInBytes"] description];
        fileSizeInBytes = [NSNumber numberWithFloat: [fileSizeInBytes intValue] / 1000 ];
        */
        
        DocumentUITableViewCell *docCell = (DocumentUITableViewCell*)cell;
        
        docCell.titleLabelText = document.fileName;
        docCell.fileSizeLabelText = document.fileDescription;
        //docCell.thumbnailImageView = [document thumbnailImage];
        
        
        //docCell.fileSizeLabelText = [NSString stringWithFormat: @"Size: %@KB",
        //                             [formatter stringForObjectValue: fileSizeInBytes]]; 
        
        //cell.detailTextLabel.text = [[managedObject valueForKey:@"fileName"] description];
        //cell.textLabel.text = [[managedObject valueForKey:@"fileName"] description];
    }

    - (void)insertNewObject
    {
        // Create a new instance of the entity managed by the fetched results controller.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        //NSNumber *randomNumber = [NSNumber numberWithUnsignedInteger: random() % 4];
        
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"SamplePresentation" withExtension:@"pptx"];
        
        
        NSError *fileAccessError = nil;
        NSDictionary *documentFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: [fileURL path] error: &fileAccessError]; // TODO: Implement exception handling
        
        
        [newManagedObject setValue:fileURL forKey:@"originalFileURL"];
        [newManagedObject setValue:[documentFileAttributes objectForKey: NSFileSize] forKey:@"originalFileSizeInBytes"];
        [newManagedObject setValue:@"pptx" forKey:@"originalFileType"];
                
        [newManagedObject setValue:[[fileURL path] lastPathComponent] forKey:@"originalFileName"];
        [newManagedObject setValue:[NSNumber numberWithInt:PENDING] forKey:@"conversionState"];
        [newManagedObject setValue:[NSDate date] forKey:@"addedTimeStamp"];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    #pragma mark - Fetched results controller

    - (NSFetchedResultsController *)fetchedResultsController
    {
        if (__fetchedResultsController != nil)
        {
            return __fetchedResultsController;
        }
        
        /*
         Set up the fetched results controller.
        */
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conversionState" ascending:YES];
        //NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"addedTimeStamp" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"conversionState" cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        //[sortDescriptorDate release];
        [sortDescriptors release];

        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error])
            {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        return __fetchedResultsController;
    }    

    #pragma mark - Fetched results controller delegate

    - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
    {
        [self.tableView beginUpdates];
    }

    - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
               atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }

    - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
           atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
          newIndexPath:(NSIndexPath *)newIndexPath
    {
        UITableView *tableView = self.tableView;
        
        switch(type)
        {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }

    - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
    {
        [self.tableView endUpdates];
    }

    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
     
     - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
    {
        // In the simplest, most efficient, case, reload the table view.
        [self.tableView reloadData];
    }
     */

@end