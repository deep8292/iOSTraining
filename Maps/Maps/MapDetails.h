

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RequestHandler.h"
@interface MapDetails : UIViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>{
    RequestHandler *sharedRequest;
}
@property(strong,nonatomic)IBOutlet UITableView *groupedTableView;
@property(strong,nonatomic)NSString* nameString;
@property(nonatomic)double latitude;
@property(nonatomic)double longitude;
@property(strong,nonatomic)NSMutableString *stringReference;

@property(strong,nonatomic)NSMutableArray *reviewArray;


@property(nonatomic)double locationLatitude;
@property(nonatomic)double locationLongitude;

@property(strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@end
