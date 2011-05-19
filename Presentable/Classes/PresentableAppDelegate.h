//
//  PresentableAppDelegate.h
//  Presentable
//
//  Created by Scott Van Vliet on 5/6/11.
//  Copyright 2011 tenseventynine, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentableAppDelegate : NSObject <UIApplicationDelegate> 
{
}
    //
    // Property outlets for UI components to be accessible through IB

    @property (nonatomic, retain) IBOutlet UIWindow *window;
    @property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

    //
    // Shared instances of Core Data objects used throughout the application

    @property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
    @property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
    @property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

    //
    // Instance method declarations for this application

    - (void)saveContext;
    - (NSURL *)applicationDocumentsDirectory;

@end
