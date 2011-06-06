//
//  PresentableAppDelegate.m
//  Presentable
//
//  Created by Scott Van Vliet on 5/6/11.
//  Copyright 2011 tenseventynine, LLC. All rights reserved.
//

#import "PresentableAppDelegate.h"
#import "RootViewController.h"
#import "Document.h"

@implementation PresentableAppDelegate


    //
    // Property outlets for UI components to be accessible through IB

    @synthesize window=_window;
    @synthesize navigationController=_navigationController;


    //
    // Shared instances of Core Data objects used throughout the app 

    @synthesize managedObjectContext=__managedObjectContext;
    @synthesize managedObjectModel=__managedObjectModel;
    @synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

    //
    // Applicaiton startup methods

    // METHOD:  application: didFinishLaunchingWithOptions:
    // 
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        // Override point for customization after application launch.
        // Add the navigation controller's view to the window and display.
        
        //RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
        
        // Light Grey
        //[[self window] setBackgroundColor:[UIColor colorWithRed:0.561 green:0.651 blue:0.722 alpha:1.0]];
        
        // Leopard Folder Blue
        [[self window] setBackgroundColor:[UIColor colorWithRed:0.627 green:0.753 blue:0.851 alpha:1.0]];
        
        /*
        [[self window] setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"MainViewBackgroundPattern" ofType:@"png"]]]];
        */
        
        // Settings.bundle init
        //
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults  objectForKey: @"AUTOSTART_CONVERSION_ON_OPEN_IN"] == nil)
        {
            /*
            [defaults setBool:NO forKey:@"AUTOSTART_CONVERSION_ON_OPEN_IN"];
            [defaults setInteger:60 forKey:@"MAX_REQUEST_TIMEOUT_IN_SECONDS"];
            */
            
            NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                NO, @"AUTOSTART_CONVERSION_ON_OPEN_IN", 
                                                60, @"MAX_REQUEST_TIMEOUT_IN_SECONDS", nil];
            [defaults registerDefaults: defaultsDictionary];
            [defaults synchronize];
        }
        
        self.window.rootViewController = self.navigationController;
        [self.window makeKeyAndVisible];
        return YES;
    }


    // METHOD:  application: handleOpenURL
    //
    // Called when the 'Open In' feature calls this application to handle
    // the opening of a file at the specified NSURL.  Used in this 
    // application to enqueue documents for conversion.
    //
    -(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
    {
        if (url)
        {
            Document *document = [NSEntityDescription 
                                  insertNewObjectForEntityForName:@"Document" 
                                  inManagedObjectContext:self.managedObjectContext];
            
            NSDictionary *documentFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: [url path] error: nil]; // TODO: Implement exception handling
            
            document.originalFileSizeInBytes = [documentFileAttributes objectForKey: NSFileSize];
            document.addedTimeStamp = [NSDate date];
            document.originalFileName = [[url path] lastPathComponent];
            document.originalFileType = [url pathExtension];
            document.originalFileURL = url;
            
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:@"AUTOSTART_CONVERSION_ON_OPEN_IN"] == [NSNumber numberWithBool:YES])
            {
                document.conversionState = [NSNumber numberWithInt:ACTIVE];
            }
            else
            {
                document.conversionState = [NSNumber numberWithInt:PENDING];
            }
            
            [self.managedObjectContext save:nil];
            
            return YES;
        }
        return NO;
    }

    // METHOD: updateApplicationIconBadgeNumber:
    //
    - (void)updateApplicationIconBadgeNumber
    {
        // TODO: Implement lazy loading of these objeccts if performance is impacted by multiple calls to
        // this method from the application
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:moc];
        [request setEntity:entity];
        
        // Specify that the request should return dictionaries.
        [request setResultType:NSDictionaryResultType];
        
        // Create an expression for the key path.
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"isUnread"];
        
        // Create an expression to represent the count value at the key path 'hasBeenRead'
        NSExpression *countExpression = [NSExpression expressionForFunction:@"sum:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description using the countExpression and returning a date.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        
        // The name is the key that will be used in the dictionary for the return value.
        [expressionDescription setName:@"unreadCount"];
        [expressionDescription setExpression:countExpression];        
        [expressionDescription setExpressionResultType:NSInteger64AttributeType];
        
        // Set the request's properties to fetch just the property represented by the expressions.
        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [moc executeFetchRequest:request error:&error];
        if (objects == nil) {
            // Handle the error.
        }
        else {
            if ([objects count] > 0) {
                //NSLog(@"Unread Count: %@", [[objects objectAtIndex:0] valueForKey:@"unreadCount"]);
                [[UIApplication sharedApplication]	setApplicationIconBadgeNumber:[[[objects objectAtIndex:0] valueForKey:@"unreadCount"] intValue]];
            }
        }
        
        [expressionDescription release];
        [request release];
        
    }

    - (void)applicationWillResignActive:(UIApplication *)application
    {
        [self updateApplicationIconBadgeNumber];
    
        /*
         Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
         Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
         */
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application
    {
        [self updateApplicationIconBadgeNumber];
        
        /*
         Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
         If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
         */
    }

    - (void)applicationWillEnterForeground:(UIApplication *)application
    {
        /*
         Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
         */
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application
    {
        /*
         Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         */
    }

    - (void)applicationWillTerminate:(UIApplication *)application
    {
        // Saves changes in the application's managed object context before the application terminates.
        [self saveContext];
    }

    - (void)dealloc
    {
        [_window release];
        [__managedObjectContext release];
        [__managedObjectModel release];
        [__persistentStoreCoordinator release];
        [_navigationController release];
        [super dealloc];
    }

    - (void)awakeFromNib
    {
        RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
        rootViewController.managedObjectContext = self.managedObjectContext;
    }

    - (void)saveContext
    {
        NSError *error = nil;
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil)
        {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
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

    #pragma mark - Core Data stack

    /**
     Returns the managed object context for the application.
     If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
     */
    - (NSManagedObjectContext *)managedObjectContext
    {
        if (__managedObjectContext != nil)
        {
            return __managedObjectContext;
        }
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil)
        {
            __managedObjectContext = [[NSManagedObjectContext alloc] init];
            [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        return __managedObjectContext;
    }

    /**
     Returns the managed object model for the application.
     If the model doesn't already exist, it is created from the application's model.
     */
    - (NSManagedObjectModel *)managedObjectModel
    {
        if (__managedObjectModel != nil)
        {
            return __managedObjectModel;
        }
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Presentable" withExtension:@"momd"];
        __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
        return __managedObjectModel;
    }

    /**
     Returns the persistent store coordinator for the application.
     If the coordinator doesn't already exist, it is created and the application's store added to it.
     */
    - (NSPersistentStoreCoordinator *)persistentStoreCoordinator
    {
        if (__persistentStoreCoordinator != nil)
        {
            return __persistentStoreCoordinator;
        }
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Presentable.sqlite"];
        
        NSError *error = nil;
        __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }    
        
        return __persistentStoreCoordinator;
    }

    #pragma mark - Application's Documents directory

    /**
     Returns the URL to the application's Documents directory.
     */
    - (NSURL *)applicationDocumentsDirectory
    {
        return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    }

@end
