
#import "MapViewController.h"
#import "RequestHandler.h"
#import "MapDetails.h"
@interface MapViewController (){
    MapDetails *map;
}
@property (strong,nonatomic) UIActivityIndicatorView *spinner;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = TRUE;
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    
    [[RequestHandler sharedRquest]detailList:self.stringReference];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showList" object:nil];
}

#pragma mark - Show Pins on map
-(void)showOnMap{
    sharedRequest = [RequestHandler sharedRquest];
    
    self.nameLabel.text = [sharedRequest.detailArray valueForKey:@"name"];
    
    double latitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
    double longitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    
    CLLocationCoordinate2D coord =  {latitude,longitude};
    
    MKPointAnnotation *pin =[[MKPointAnnotation alloc]init];
    
    pin.coordinate = coord;
    pin.title = [sharedRequest.detailArray valueForKey:@"name"];
    [self.mapView addAnnotation:pin];
    
    [self.spinner stopAnimating];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    sharedRequest = [RequestHandler sharedRquest];
    
    map = [[MapDetails alloc]initWithNibName:@"MapDetails" bundle:nil];
    
    map.nameString =  [sharedRequest.detailArray valueForKey:@"name"];
    
    map.latitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
    map.longitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    
    [self.navigationController pushViewController:map animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    sharedRequest = [RequestHandler sharedRquest];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    static NSString *annotationID = @"MyAnnotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationID] ;
    
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationID];
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.image = [UIImage imageNamed:@"map_pin.png"];
        }

    return pinView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
