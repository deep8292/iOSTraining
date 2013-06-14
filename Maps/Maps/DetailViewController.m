
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    [self showOnMap];
        
    self.mapView.showsUserLocation = TRUE;
    self.mapView.delegate = self;
}

- (void)showOnMap
{
    sharedRequest = [RequestHandler sharedRquest];
    
    for (int i=0 ; i<[sharedRequest.dataArray count] ; i++) {
        
        NSMutableDictionary * location = [[[sharedRequest.dataArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
                double lat = [[location objectForKey:@"lat"]doubleValue];
        double lng = [[location objectForKey:@"lng"]doubleValue];
        NSString *name = [[sharedRequest.dataArray objectAtIndex:i]objectForKey:@"name"];
        NSLog(@"%@",name);
        CLLocationCoordinate2D coord = {lat,lng};
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = coord;
        point.title =name;
        [self.view addSubview:self.mapView];
        [self.mapView addAnnotation:point];
    }
    [_spinner stopAnimating];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    static NSString *reuseId = @"StandardPin";
    
    MKPinAnnotationView *aView = (MKPinAnnotationView *)[mapView
                                                         dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (aView == nil)
    {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                 reuseIdentifier:reuseId];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.canShowCallout = YES;
    }
    
    aView.annotation = annotation;
    
    return aView;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    sharedRequest = [RequestHandler sharedRquest];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
