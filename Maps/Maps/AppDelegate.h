//
//  AppDelegate.h
//  Maps
//
//  Created by Deepak Khiwani on 14/06/13.
//  Copyright (c) 2013 Deepak Khiwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)UIWindow *window;
@property (strong,nonatomic)UINavigationController *navigation;
@property (strong, nonatomic)ViewController *viewController;

@property (strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
