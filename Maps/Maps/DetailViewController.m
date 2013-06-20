
#import "DetailViewController.h"
#import "RequestHandler.h"

@interface DetailViewController ()
@property (strong,nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.longitude];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showAllData" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showRestaurantData) name:@"Restaurant" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showCoffeeShopData) name:@"CoffeeShop" object:nil];
    
    
    
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
}

#pragma mark - showing pins on map
- (void)showOnMap
{
    sharedRequest = [RequestHandler sharedRquest];
    
    for (int i=0 ; i<[sharedRequest.name count] ; i++) {
        double lat = [[sharedRequest.location valueForKey:@"lat"]doubleValue];
        double lng = [[sharedRequest.location valueForKey:@"lng"]doubleValue];
        CLLocationCoordinate2D coord = {lat,lng};
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = coord;
        point.title =[sharedRequest.name objectAtIndex:i];
        [self.view addSubview:self.mapView];
        [self.mapView addAnnotation:point];
    }
    [_spinner stopAnimating];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    static NSString *annotationID = @"MyAnnotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationID] ;
    
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationID];
        pinView.canShowCallout = YES;
        pinView.image = [UIImage imageNamed:@"map_pin.png"];
    }
    
    return pinView;
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    sharedRequest = [RequestHandler sharedRquest];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}

//#pragma mark - Restaurants
//-(IBAction)restaurantsClicked:(id)sender{
//    
//    NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ];
//    
//    [ _mapView removeAnnotations:annotationsToRemove] ;
//    
//    sharedRequest = [RequestHandler sharedRquest];
//    
//    [_spinner startAnimating];
//    
//    [[RequestHandler sharedRquest]restaurantsResults:self.latitudeString longitude:self.longitudeString];
//}
//
//-(void)showRestaurantData{
//    
//     sharedRequest = [RequestHandler sharedRquest];
//    
//    for (int i = 0; i <[sharedRequest.restautrantsArray count]; i++)
//    {
//        NSMutableDictionary *location  = [[[sharedRequest.restautrantsArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
//        double lat = [[location objectForKey:@"lat"]doubleValue];
//        double lng = [[location objectForKey:@"lng"]doubleValue];
//        
//        CLLocationCoordinate2D coord = {lat,lng};
//        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
//        point.coordinate = coord;
//        point.title = [[sharedRequest.restautrantsArray objectAtIndex:i]objectForKey:@"name"];
//        [self.mapView addAnnotation:point];
//        
//         [_spinner stopAnimating];
//    }
//}
//
//#pragma mark - CoffeeShops
//-(IBAction)coffeeShopsClicked:(id)sender{
//    NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ];
//    
//    [ _mapView removeAnnotations:annotationsToRemove] ;
//    
//    sharedRequest = [RequestHandler sharedRquest];
//    
//    [_spinner startAnimating];
//    
//    [[RequestHandler sharedRquest]coffeeShopsResults:self.latitudeString longitude:self.longitudeString];
//}
//
//-(void)showCoffeeShopData{
//    
//    sharedRequest = [RequestHandler sharedRquest];
//    
//    for (int i = 0; i <[sharedRequest.coffeeShopsArray count]; i++)
//    {
//        NSMutableDictionary *location  = [[[sharedRequest.restautrantsArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
//        double lat = [[location objectForKey:@"lat"]doubleValue];
//        double lng = [[location objectForKey:@"lng"]doubleValue];
//        
//        CLLocationCoordinate2D coord = {lat,lng};
//        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
//        point.coordinate = coord;
//        point.title = [[sharedRequest.coffeeShopsArray objectAtIndex:i]objectForKey:@"name"];
//        [self.mapView addAnnotation:point];
//        
//        [_spinner stopAnimating];
//    }
//}
//
//#pragma mark - Mechanics
//-(IBAction)mechanicsClicked:(id)sender{
//    NSMutableArray * annotationsToRemove = [ self.mapView.annotations mutableCopy ];
//    
//    [ _mapView removeAnnotations:annotationsToRemove] ;
//    
//    sharedRequest = [RequestHandler sharedRquest];
//    
//    [_spinner startAnimating];
//    
//    [[RequestHandler sharedRquest]mechanicsData:self.latitudeString longitude:self.longitudeString];
//}
//
//-(void)showMechanicsData{
//    
//    sharedRequest = [RequestHandler sharedRquest];
//    
//    for (int i = 0; i <[sharedRequest.mechanicsArray count]; i++)
//    {
//        NSMutableDictionary *location  = [[[sharedRequest.restautrantsArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
//        double lat = [[location objectForKey:@"lat"]doubleValue];
//        double lng = [[location objectForKey:@"lng"]doubleValue];
//        
//        CLLocationCoordinate2D coord = {lat,lng};
//        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
//        point.coordinate = coord;
//        point.title = [[sharedRequest.mechanicsArray objectAtIndex:i]objectForKey:@"name"];
//        [self.mapView addAnnotation:point];
//        
//        [_spinner stopAnimating];
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
