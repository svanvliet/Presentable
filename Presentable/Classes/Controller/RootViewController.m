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
#import "PresentableAppDelegate.h"

typedef enum
{
    ON_FAILURE_ASK_RESTART,
    ON_SELECT_FAILED_ASK_RESTART
} 
UIAlertViewTagType;

@interface RootViewController
(
)
    //
    // Instance method declarations for this application

    - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
    - (void)uploadStarted:(ASIHTTPRequest *)request;
    - (void)uploadFailed:(ASIHTTPRequest *)request;
    - (void)uploadFinished:(ASIHTTPRequest *)request;
    - (void)convertDocument:(Document*)document withIndexPath:(NSIndexPath*)indexPath;
    - (void)showHideStatusView:(BOOL)shouldShow;

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
                
        requestQueue = [[ASINetworkQueue alloc] init];
        [requestQueue setMaxConcurrentOperationCount: 1];
        [requestQueue setShowAccurateProgress: YES];
        [requestQueue setUploadProgressDelegate:progressView];
        [requestQueue setDownloadProgressDelegate:progressView];
        [requestQueue setDelegate: self];
        [requestQueue setRequestDidFailSelector:@selector(uploadFailed:)];
        [requestQueue setRequestDidFinishSelector:@selector(uploadFinished:)];
        
        [requestQueue setRequestDidStartSelector:@selector(uploadStarted:)];
        
        // Hide the statusView area
        //[(UITableView*)self.view setTableHeaderView: statusView];
        [self showHideStatusView: NO];
    }

    //
    // Standard UI behavior methods

    // METHOD:  shouldAutorotateToInterfaceOrientation:
    // 
    -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
    {
        return YES;
    }

    -(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
    {
        /*
        PresentableAppDelegate *appDelegate = (PresentableAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[appDelegate window] setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"MainViewBackgroundPattern" ofType:@"png"]]]];
        */
    }

    // METHOD: resetProgress:
    //
    -(void)resetProgress
    {
        progressView.progress = 0.0f;
    }

    // METHOD: showHideStatusView
    //
    -(void)showHideStatusView:(BOOL)shouldShow
    {
        /*
        UITableView *tableView = (UITableView*)self.view;
        
        [tableView setTableHeaderView: nil];
        
        if (shouldShow)
        {
            [statusView setFrame: CGRectMake(statusView.frame.origin.x, statusView.frame.origin.y, statusView.frame.size.width, 0.0f)];
        }
        else
         {
                 [statusView setFrame: CGRectMake(statusView.frame.origin.x, statusView.frame.origin.y, statusView.frame.size.width, 30.0f)];            
        }
        
        [tableView setTableHeaderView: statusView];
        */
       
        [statusView setHidden: !shouldShow];
        //[self.view layoutSubviews];
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

    // METHOD: tableView: heightForHeaderInSection
    //
    - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
    {
        return 55;
    }

    // METHOD:  tableView: viewForHeaderInSection:
    // 
    - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        int conversionState = [[sectionInfo name] intValue];
        
        UIView *placeholderView = [[UIView alloc] init];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"FolderTab" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile: imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
        [placeholderView addSubview: imageView];
    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(49, 14, 220, 24)];
                
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName: @"AmericanTypewriter-Bold" size: 17.0f];
        label.textAlignment = UITextAlignmentCenter;
        label.text = [Document documentConversionStateTypeString: conversionState]; // Should be a localized value
        [placeholderView addSubview: label];
        
        return placeholderView;
    }

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
        
        selectedIndexPath = indexPath;
        selectedDocument = (Document*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        UIAlertView *alert = nil;
        
        switch ([selectedDocument.conversionState intValue]) 
        {
            case PENDING:
                
                [self convertDocument: selectedDocument withIndexPath:indexPath];
                break;
                
            case COMPLETED:
                
                documentController = [UIDocumentInteractionController interactionControllerWithURL:selectedDocument.convertedFileURL];
                documentController.delegate = self;
                [documentController presentPreviewAnimated:YES];
                
                break;
                
            case FAILED:
                
                alert = [[[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you wish to retry converting the selected document ?" delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
                
                [alert addButtonWithTitle: @"Yes"]; // Index: 0
                [alert addButtonWithTitle: @"No"];  // Index: 1
                [alert setTag: ON_SELECT_FAILED_ASK_RESTART];
                [alert show];
                
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                break;
                
            default:
                
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

    // Modal dialog handling
    //

    // METHOD:
    //
    -(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
    {
        if (alertView.tag == ON_FAILURE_ASK_RESTART)
        {
            if (buttonIndex == 0) // YES
            {
                [self convertDocument:failedDocument withIndexPath:failedIndexPath];
                failedDocument = nil;
                failedIndexPath = nil;
            }
        }
        else if (alertView.tag == ON_SELECT_FAILED_ASK_RESTART)
        {            
            if (buttonIndex == 0) // YES
            {
                [self convertDocument:selectedDocument withIndexPath:selectedIndexPath];
                selectedDocument = nil;
                selectedIndexPath = nil;
            }
        }
    }

    //
    // HTTP request handling methods

    // METHOD
    //
    -(void)convertDocument:(Document*)document withIndexPath:(NSIndexPath*)indexPath
    {    
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        selectedDocument.conversionState = [NSNumber numberWithInt:ACTIVE];
        selectedDocument.conversionStartedTimeStamp = [NSDate date];
        [context save:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int timeout = (int)[defaults objectForKey:@"MAX_REQUEST_TIMEOUT_IN_SECONDS"];
        [ASIHTTPRequest setDefaultTimeOutSeconds: timeout];
        
        ASIFormDataRequest *uploadRequest = [ASIFormDataRequest 
                                             requestWithURL: [NSURL URLWithString:@"http://dev.cloud.tenseventynine.com/PresentableServices/ConvertDocument"]];
        
        if (!uploadRequest.userInfo)
        {
            uploadRequest.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: document, @"document", nil];
        }
        
        [uploadRequest setPostValue:indexPath forKey:@"documentIndexPath"];
        [uploadRequest setPostValue:[[document objectID] URIRepresentation] forKey:@"documentID"];
        [uploadRequest setFile:[[document originalFileURL] path] forKey:@"document"];
        
        [requestQueue addOperation: uploadRequest];
        [requestQueue go];
        
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        [uploadRequest setShouldContinueWhenAppEntersBackground:YES];
        #endif
    }

    // METHOD: requestStarted:
    //
    -(void)uploadStarted:(ASIHTTPRequest *)request
    {
        [self showHideStatusView: YES];
    }

    // METHOD:  uploadFailed:
    // 
    -(void)uploadFailed:(ASIHTTPRequest *)request
    {
        [self showHideStatusView: NO];
    
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        failedDocument = (Document*)[request.userInfo objectForKey: @"document"];
        failedDocument.conversionState = [NSNumber numberWithInt: FAILED];
        failedDocument.conversionStartedTimeStamp = nil;
        [context save: nil];
        
        [request.userInfo release];
        request.userInfo = nil;
        
        [self resetProgress];
        
        NSString *errorDescription = [NSString stringWithFormat:@"There was a problem with the conversion request (%@).\n\n  Would you like to try again?", [[request error] localizedDescription], nil];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Whoops!" message: errorDescription delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
                
        [alert addButtonWithTitle: @"Yes"]; // Index: 0
        [alert addButtonWithTitle: @"No"];  // Index: 1
        [alert setTag: ON_FAILURE_ASK_RESTART];
        [alert show];
    }

    // METHOD:  uploadFinished:
    //
    -(void)uploadFinished:(ASIHTTPRequest *)request
    {       
        [self showHideStatusView: NO];
    
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
        document.thumbnailImageData = UIImagePNGRepresentation([Document PDFPageThumbnailImage: document.convertedFileURL]);
        
        [context save: nil]; // TODO: Implement exception handling
        
        [self resetProgress];
        
        [request.userInfo release];
        request.userInfo = nil;
        
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
        [statusView release];
        statusView = nil;
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
        [statusView release];
        [super dealloc];
    }

    - (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
    {
        Document *document = (Document*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        DocumentUITableViewCell *docCell = (DocumentUITableViewCell*)cell;
        
        docCell.titleLabelText = document.fileName;
        docCell.fileSizeLabelText = document.fileSizeDescription;
        docCell.fileTimestampLabelText = document.fileTimestampDescription;
        
        if ([document.conversionState intValue] == COMPLETED)
        {
            docCell.thumbnailImage = [UIImage imageWithData: document.thumbnailImageData];
        }
        else
        {
            docCell.thumbnailImage = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"DefaultThumbnail" ofType:@"png"]];
        }
                
        // Check for documents that have been flagged as ACTIVE with no start time (from handleLoadULR)
        // and see if we should autostart the conversion
        //
        /*
        if ([document.conversionState intValue] == ACTIVE && 
            document.conversionStartedTimeStamp == nil)
        {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            bool shouldAutostart = (bool)[defaults objectForKey:@"AUTOSTART_CONVERSION_ON_OPEN_IN"];
            if (shouldAutostart)
            {
                [self convertDocument: selectedDocument withIndexPath:indexPath];
            }
        }
        */
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
