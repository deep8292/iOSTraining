

#import <UIKit/UIKit.h>
#import "RequestHandler.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface DetailViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
     CLLocationManager *locationManager;
     RequestHandler *sharedRequest;
}
@property (strong,nonatomic)IBOutlet MKMapView *mapView;
@property (strong,nonatomic)NSString *stringReference;
@property (strong,nonatomic)NSMutableString *latitudeString;
@property (strong,nonatomic)NSMutableString *longitudeString;

-(IBAction)restaurantsClicked:(id)sender;
-(IBAction)coffeeShopsClicked:(id)sender;
-(IBAction)mechanicsClicked:(id)sender;
@end
