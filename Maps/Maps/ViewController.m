#import "ViewController.h"
#import "RequestHandler.h"
#import "DetailViewController.h"
#import "MapViewController.h"
#import "MapDetails.h"
@interface ViewController ()
@property (strong,nonatomic)UIActivityIndicatorView *spinner;
@property (strong,nonatomic)NSString *referenceString;
@end

@implementation ViewController

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
    self.spinner.frame = CGRectMake(0, 44, 320, 480);
    [self.view addSubview:_spinner];
//    [_spinner startAnimating];
    
    //Table View and Search Delegates
    _table.delegate=self;
    _table.dataSource=self;
    _searchBar.delegate=self;
    
    self.table.hidden = TRUE;
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 44, 320, 560)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:@"Doreload" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showAllData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showDetail) name:@"showList" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [_searchBar resignFirstResponder];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.longitude];
    
}

#pragma mark - Map 
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}

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
//        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return pinView;
}

-(void)showDetail{
    
    NSString *str = [[NSString alloc]init];
    
    str = [sharedRequest.detailArray valueForKey:@"name"];
    
    NSLog(@"%@",str);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    sharedRequest = [RequestHandler sharedRquest];
    
    MapDetails *map = [[MapDetails alloc]initWithNibName:@"MapDetails" bundle:nil];
    
    map.nameString =  [sharedRequest.detailArray valueForKey:@"name"];
    
    map.latitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
    map.longitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    
    [self.navigationController pushViewController:map animated:YES];
}

#pragma mark - Search Bar

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{   self.table.hidden = FALSE;
    self.mapView.hidden = TRUE;
    
    _table.scrollEnabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self startSearch];
    _table.scrollEnabled = YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    self.table.hidden = TRUE;
    self.mapView.hidden = FALSE;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[RequestHandler sharedRquest]showAllData:sharedRequest.referenceNameArray];
    
    self.table.hidden = TRUE;
    
    [self.spinner startAnimating];
    
    self.mapView.hidden = FALSE;
    
    [self.searchBar resignFirstResponder];
    
//    [_searchBar resignFirstResponder];
//    
//    DetailViewController *details = [[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - Getting keyword from Search Bar

-(void)startSearch
{
    _searchString = [[NSString alloc]init];
    _searchString = _searchBar.text;
    [[RequestHandler sharedRquest]getData:_searchString latitude:self.latitudeString longitude:self.longitudeString];
}

#pragma mark - Table View

-(void)reloadData
{
    [self.table reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    sharedRequest = [RequestHandler sharedRquest];
    
    return [sharedRequest.dataArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sharedRequest = [RequestHandler sharedRquest];
    
    static NSString *cellID = @"Cell Identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [[sharedRequest.dataArray objectAtIndex:indexPath.row]objectForKey:@"description"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapViewController *mapDetails = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];

    mapDetails.stringReference = [[sharedRequest.dataArray objectAtIndex:indexPath.row]objectForKey:@"reference"];

    [self.navigationController pushViewController:mapDetails animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
