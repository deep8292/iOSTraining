//
//  AppDelegate.m
//  Maps
//
//  Created by Deepak Khiwani on 14/06/13.
//  Copyright (c) 2013 Deepak Khiwani. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import <CoreData/CoreData.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    self.navigation = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navigation;
    [self.window makeKeyAndVisible];
    return YES;
}

-(NSManagedObjectContext *)managedObjectContext{
    if (self.managedObjectContext != nil) {
        return self.managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator!=nil) {
        self.managedObjectContext = [[NSManagedObjectContext alloc]init];
        [self.managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return self.managedObjectContext;
}

-(NSManagedObjectModel *)managedObjectModel{
    if (self.managedObjectModel != nil ) {
        return self.managedObjectModel;
    }
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return self.managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (self.persistentStoreCoordinator!=nil) {
        return self.persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentDirectory]URLByAppendingPathComponent:@"FavModel.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    } 
    return _persistentStoreCoordinator;

}

-(NSURL *)applicationDocumentDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
