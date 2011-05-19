//
//  RootViewController.h
//  Presentable
//
//  Created by Scott Van Vliet on 5/6/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ASINetworkQueue.h"
#import "DocumentUITableViewCell.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIDocumentInteractionControllerDelegate, ASIHTTPRequestDelegate> 
{
    //
    // Property outlets for UI components to be accessible through IB
    
    IBOutlet UIProgressView *progressView;
}
    //
    // Property definitions

    @property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
    @property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
    @property (nonatomic, retain) ASINetworkQueue *requestQueue;
    @property (nonatomic, assign) IBOutlet DocumentUITableViewCell *documentCell;


@end
