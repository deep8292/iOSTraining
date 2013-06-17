

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RequestHandler.h"
#import <CoreLocation/CoreLocation.h>
@interface MapViewController : UIViewController<MKMapViewDelegate>{
    RequestHandler *sharedRequest;
}
@property(strong,nonatomic)IBOutlet MKMapView *mapView;
@property(strong,nonatomic)IBOutlet UILabel *nameLabel;
@property(strong,nonatomic)NSMutableString *stringReference;
@end
