#import <UIKit/UIKit.h>
#import "RequestHandler.h"
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
{RequestHandler *sharedRequest;
    CLLocationManager *locationManager;
}
@property (strong,nonatomic)IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic)IBOutlet UITableView *table;
@property (strong,nonatomic)NSString *searchString;
@property (strong,nonatomic)NSMutableArray *array;
@property (strong,nonatomic)NSMutableString *latitudeString;
@property (strong,nonatomic)NSMutableString *longitudeString;
@end
