

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FbLoginViewController.h"
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)UIWindow *window;
@property (strong,nonatomic)UINavigationController *navigation;
@property (strong, nonatomic)ViewController *viewController;

@property (strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong,nonatomic)FbLoginViewController *loginViewController;
@end
