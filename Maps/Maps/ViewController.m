
#import "ViewController.h"
#import "RequestHandler.h"
#import "DetailViewController.h"
#import "MapViewController.h"
#import "MapDetails.h"
#import "Favourites.h"
#import "AppDelegate.h"
#import "FbLoginViewController.h"
#import "AppDelegate.h"
@interface ViewController ()

@property (strong,nonatomic)UIActivityIndicatorView *spinner;
@property (strong,nonatomic)NSString *referenceString;
@property (strong,nonatomic)NSString *titleName;
@property (strong,nonatomic)NSString *savedNameString;
@property (nonatomic)double savedLatitude;
@property (nonatomic)double savedLongitude;
@property (nonatomic)int indexOfButton;
@property (strong,nonatomic)NSString *pressedButtonName;

@property (strong,nonatomic)NSMutableArray *placeNameArray;
@property (strong,nonatomic)NSMutableArray *placeLatitudeArray;
@property (strong,nonatomic)NSMutableArray *placeLongitudeArray;

@property (strong,nonatomic)NSMutableArray *savedArray;
@end


@implementation ViewController


-(id)init{
    
    id delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [delegate managedObjectContext];
    return [super init];
}

#pragma mark - View Life Cycle
-(void)viewWillAppear:(BOOL)animated{
    [_searchBar resignFirstResponder];
    self.navigationController.navigationBar.hidden = TRUE;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.longitude];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeNameArray = [[NSMutableArray alloc]init];
    self.placeLatitudeArray= [[NSMutableArray alloc]init];
    self.placeLongitudeArray = [[NSMutableArray alloc]init];;
    self.navigationController.navigationBar.hidden = TRUE;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 44, 320, 480);
    [self.view addSubview:_spinner];
    
    //Table View and Search Delegates
    _table.delegate=self;
    _table.dataSource=self;
    _searchBar.delegate=self;
    
    self.table.hidden = TRUE;
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 44, 320, 400)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    [self creatingButtons];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:@"Doreload" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showAllData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveFromTable) name:@"newList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showPlacesData) name:@"showPlaces" object:nil];
    
}

#pragma mark - Facebook Button Pressed

-(void)facebookButtonPressed{
    
    FbLoginViewController *login = [[FbLoginViewController alloc]initWithNibName:@"FbLoginViewController" bundle:nil];
    [self.navigationController pushViewController:login animated:YES];
}


#pragma mark - Adding buttons
-(void)creatingButtons{
    
    
    facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookButton setBackgroundImage:[UIImage imageNamed:@"fbButton.png"] forState:UIControlStateNormal];
    facebookButton.frame = CGRectMake(20, 350, 20, 20);
    [self.mapView addSubview:facebookButton];
    [facebookButton addTarget:self action:@selector(facebookButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    restaurantButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [restaurantButton setTitle:@"Restaurants" forState:UIControlStateNormal];
    restaurantButton.frame = CGRectMake(7, 450, 110, 40);
    [self.view addSubview:restaurantButton];
    [restaurantButton addTarget:self action:@selector(restaurantButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    restaurantButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    coffeshopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [coffeshopButton setTitle:@"Coffee Shops" forState:UIControlStateNormal];
    coffeshopButton.frame = CGRectMake(7, 500, 110, 40);
    [self.view addSubview:coffeshopButton];
    [coffeshopButton addTarget:self action:@selector(coffeeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    coffeshopButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    mechanicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mechanicButton setTitle:@"Mechanics" forState:UIControlStateNormal];
    mechanicButton.frame = CGRectMake(227, 450, 90, 40);
    [self.view addSubview:mechanicButton];
    [mechanicButton addTarget:self action:@selector(mechanicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    mechanicButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    favouriteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [favouriteButton setTitle:@"Favourite" forState:UIControlStateNormal];
    favouriteButton.frame = CGRectMake(227, 500, 90, 40);
    [self.view addSubview:favouriteButton];
    [favouriteButton addTarget:self action:@selector(favouiteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    favouriteButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - Restaurants button clicked
-(void)restaurantButtonClicked:(id)sender{

    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"PerofomDeletion"];
    
    self.pressedButtonName = [sender currentTitle];
    
    NSLog(@"Button pressed: %@", self.pressedButtonName);
    
    if (self.mapView.annotations == nil) {
        NSLog(@"Map is already nil!!");
    }
    else{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSString *string = @"restaurants";
    
    sharedRequest = [RequestHandler sharedRquest];
    
    [_spinner startAnimating];
    
    [[RequestHandler sharedRquest]placeResults:self.latitudeString longitude:self.longitudeString searchKeyword:string];
    }
}

#pragma mark - Coffee button clicked
-(void)coffeeButtonClicked:(id)sender{
    
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"PerofomDeletion"];
    
    self.pressedButtonName = [sender currentTitle];
    
    NSLog(@"Button pressed: %@", self.pressedButtonName);
    
    if (self.mapView.annotations == nil) {
        NSLog(@"Map is already nil!!");
    }
    else{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSString *string = @"coffee shops";
    
    sharedRequest = [RequestHandler sharedRquest];
    
    [_spinner startAnimating];
    
    [[RequestHandler sharedRquest]placeResults:self.latitudeString longitude:self.longitudeString searchKeyword:string];
    }
}
#pragma mark - Mechanic button clicked
-(void)mechanicButtonClicked:(id)sender{
    
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"PerofomDeletion"];
    
    self.pressedButtonName = [sender currentTitle];
    
    NSLog(@"Button pressed: %@", self.pressedButtonName);
    
    if (self.mapView.annotations == nil) {
        NSLog(@"Map is already nil!!");
    }
    else{
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSString *string = @"mechanics";
    
    sharedRequest = [RequestHandler sharedRquest];
    
    [_spinner startAnimating];
    
    [[RequestHandler sharedRquest]placeResults:self.latitudeString longitude:self.longitudeString searchKeyword:string];
        
    sharedRequest = [RequestHandler sharedRquest];
        
    [_spinner startAnimating];
        
    
    }
}

#pragma mark - Placing pins on map on the basis of button
-(void)showPlacesData{
    sharedRequest = [RequestHandler sharedRquest];
    
    [_spinner startAnimating];
    
    for (int i = 0; i <[sharedRequest.placeArray count]; i++)
    {
        NSMutableDictionary *location  = [[[sharedRequest.placeArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
        double lat = [[location objectForKey:@"lat"]doubleValue];
        double lng = [[location objectForKey:@"lng"]doubleValue];
        
        CLLocationCoordinate2D coord = {lat,lng};
        MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
        point.coordinate = coord;
        point.title = [[sharedRequest.placeArray objectAtIndex:i]objectForKey:@"name"];
        [self.mapView addAnnotation:point];
        
        [_spinner stopAnimating];
    }
    
}

#pragma mark - Favourite button clicked
-(void)favouiteButtonClicked:(id)sender
{
//    self.mapView.showsUserLocation = FALSE;
    self.pressedButtonName = [sender currentTitle];
    
    NSLog(@"Button pressed: %@", self.pressedButtonName);
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"savedData"])
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [_spinner startAnimating];
        [self fetchRecords];
        NSLog(@"%@",self.savedArray);
        for (int i =0; i<[_savedArray count]; i++)
        {
            Favourites *fav = [_savedArray objectAtIndex:i];
            double lat = [fav.placeLatitude doubleValue];
            double lng = [fav.placeLongitude doubleValue];
            NSLog(@"%f,%f",lat,lng);
            CLLocationCoordinate2D coord = {lat,lng};
            MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
            point.coordinate = coord;
            point.title = fav.placeName;
            [self.mapView addAnnotation:point];
        }
        [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"savedData"];
        [_spinner stopAnimating];

    }
    else
    {
        if (![[NSUserDefaults standardUserDefaults]boolForKey:@"DataSavedSucessfully"])
        {
            NSLog(@"Map is already nil!!");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Favorites" message:@"You have no favorites" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"savedData"];
        }
        else
        {
            [self.mapView removeAnnotations:self.mapView.annotations];
            [_spinner startAnimating];
            [self fetchRecords];
            for (int i =0; i<[_savedArray count]; i++) {
                Favourites *fav = [_savedArray objectAtIndex:i];
                double lat = [fav.placeLatitude doubleValue];
                double lng = [fav.placeLongitude doubleValue];
                NSLog(@"%f,%f",lat,lng);
                CLLocationCoordinate2D coord = {lat,lng};
                MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
                point.coordinate = coord;
                point.title = fav.placeName;
                [self.mapView addAnnotation:point];
        }
            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"savedData"];
            [_spinner stopAnimating];
    
        }
    }
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"PerfomDeletion"];
}


-(void)fetchRecords{
    NSEntityDescription *favourites = [NSEntityDescription entityForName:@"Favourites" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:favourites];
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    [self setSavedArray:mutableFetchResults];
}

#pragma mark - Map 
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}


- (void)showOnMap                       // Method to show all the places on map.
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


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation         //  Method to handle all the annotations on map.
{
    
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    static NSString *annotationID = @"MyAnnotation";
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationID] ;
    
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationID];
        pinView.canShowCallout = YES;
        pinView.image = [UIImage imageNamed:@"map_pin.png"];
        
        //Setting Right call button
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
       
        //Setting Left Call button
        self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favButton.frame = CGRectMake(0, 0, 23, 23);
        self.favButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.favButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.favButton setImage:[UIImage imageNamed:@"favourite.png"] forState:UIControlStateNormal];
        pinView.leftCalloutAccessoryView = self.favButton;
    }
    return pinView;
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control     // Method to process request when accessory button is tapped
{
    sharedRequest = [RequestHandler sharedRquest];
    
     MKPointAnnotation *point = view.annotation;
    
    if (control == view.rightCalloutAccessoryView)
    {
        MapDetails *details = [[MapDetails alloc]initWithNibName:@"MapDetails" bundle:nil];
       
        NSString *str = [NSString stringWithFormat:@"%@",point.title];
        
        if ([self.pressedButtonName isEqualToString:@"Coffee Shops"] || [self.pressedButtonName isEqualToString:@"Restaurants"] || [self.pressedButtonName isEqualToString:@"Mechanics"])
        {
            int index =[sharedRequest.name indexOfObject:str];
            
            double lat = [[sharedRequest.placeLatAray objectAtIndex:index]doubleValue];
            double lng = [[sharedRequest.placeLngAray objectAtIndex:index]doubleValue];
            details.locationLatitude = lat;
            details.locationLongitude = lng;
            details.nameString = str;
        }
        else if ([self.pressedButtonName isEqualToString:@"Favourite"]){
            NSMutableArray *savedNameArray = [[NSMutableArray alloc]init];
            NSMutableArray *savedLatArray = [[NSMutableArray alloc]init];
            NSMutableArray *savedLngArray = [[NSMutableArray alloc]init];
            for (int i =0; i<[_savedArray count]; i++)
            {
                Favourites *fav = [_savedArray objectAtIndex:i];
                double lat = [fav.placeLatitude doubleValue];
                double lng = [fav.placeLongitude doubleValue];
                NSMutableString *savedLatString = [[NSMutableString alloc]initWithFormat:@"%f",lat ];
                NSMutableString *savedLngString = [[NSMutableString alloc]initWithFormat:@"%f",lng ];
                NSLog(@"%f,%f",lat,lng);
                CLLocationCoordinate2D coord = {lat,lng};
                MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
                point.coordinate = coord;
                point.title = fav.placeName;
                [self.mapView addAnnotation:point];
                [savedNameArray addObject:point.title];
                [savedLatArray addObject:savedLatString];
                [savedLngArray addObject:savedLngString];
            }
            
            int index = [savedNameArray indexOfObject:str];
            details.nameString = str;
            double lat = [[savedLatArray objectAtIndex:index]doubleValue];
            details.locationLatitude = lat;
            double lng = [[savedLngArray objectAtIndex:index]doubleValue];
            details.locationLongitude = lng;
            
        }
        else{
            
        int index =[sharedRequest.name indexOfObject:str];
            
        NSMutableArray * reviews = [sharedRequest.reviewDictionary objectForKey:str];
        
        details.reviewArray = [NSMutableArray arrayWithArray:reviews];
               
        double lat = [[sharedRequest.latArray objectAtIndex:index]doubleValue];
        double lng = [[sharedRequest.lngArray objectAtIndex:index]doubleValue];
        
        details.locationLatitude = lat;
        details.locationLongitude = lng;
        details.nameString = str;
        }
        [self.navigationController pushViewController:details animated:YES];}
    else
    {   //Detleting annotations from map (favorites)
            NSString *str = [NSString stringWithFormat:@"%@",point.title];
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"PerfomDeletion"])
            {
                NSMutableArray *nameToBeRemoved = [[NSMutableArray alloc]init];
                NSString *name;
                for (int i =0; i<[_savedArray count]; i++)
                {
                    Favourites *fav = [_savedArray objectAtIndex:i];
                    name = [[NSMutableString alloc]initWithFormat:@"%@",fav.placeName];
                    [nameToBeRemoved addObject:name];
                }
                int indexToBeRemoved = [nameToBeRemoved indexOfObject:name];
                NSManagedObject *newContext = [self.savedArray objectAtIndex:indexToBeRemoved];
                [_managedObjectContext deleteObject:newContext];
                
                NSError *error;
                
                if (![_managedObjectContext save:&error]) {
                    NSLog(@"Error %@", [error localizedDescription]);
                }
                
                [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"DataSavedSucessfully"];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Removed" message:@"Removed from Favourites" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                [self.mapView removeAnnotation:point];
            }
        
        //Adding annotations to map(favorites)
            else
            {
            Favourites *fav = (Favourites *)[NSEntityDescription insertNewObjectForEntityForName:@"Favourites" inManagedObjectContext:_managedObjectContext];
        
            int index =[sharedRequest.name indexOfObject:str];
        
            [fav setPlaceName:str];
        
            if ([self.pressedButtonName isEqualToString:@"Coffee Shops"] || [self.pressedButtonName isEqualToString:@"Restaurants"] || [self.pressedButtonName isEqualToString:@"Mechanics"])
            {
                double lat = [[sharedRequest.placeLatAray objectAtIndex:index]doubleValue];
                NSString *str1 = [[NSString alloc]initWithFormat:@"%f",lat ];
                double lng = [[sharedRequest.placeLngAray objectAtIndex:index]doubleValue];
                NSString *str2 = [[NSString alloc]initWithFormat:@"%f",lng];
            
                [fav setPlaceLatitude:str1];
                [fav setPlaceLongitude:str2];
            }
        
            else
            {
                double lat = [[sharedRequest.latArray objectAtIndex:index]doubleValue];
                NSString *str1 = [[NSString alloc]initWithFormat:@"%f",lat ];
                double lng = [[sharedRequest.lngArray objectAtIndex:index]doubleValue];
                NSString *str2 = [[NSString alloc]initWithFormat:@"%f",lng];
        
                [fav setPlaceLatitude:str1];
                [fav setPlaceLongitude:str2];
            }
            NSError *error;
        
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Error %@", [error localizedDescription]);
            }
        
            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"DataSavedSucessfully"];
        
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Added" message:@"Added To Favourites" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - Search Bar

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar   
{   self.table.hidden = FALSE;
    restaurantButton.hidden = TRUE;
    coffeshopButton.hidden = TRUE;
    mechanicButton.hidden = TRUE;
    favouriteButton.hidden = TRUE;
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
    restaurantButton.hidden = FALSE;
    coffeshopButton.hidden = FALSE;
    mechanicButton.hidden = FALSE;
    favouriteButton.hidden = FALSE;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"PerofomDeletion"];
    
    if (self.mapView.annotations == nil) {
        NSLog(@"Map is already nil!!");
    }
    else{
        
        [self.mapView removeAnnotations:self.mapView.annotations];}
    
    [[RequestHandler sharedRquest]showAllData:sharedRequest.referenceNameArray];
    
    self.table.hidden = TRUE;
    
    [self.spinner startAnimating];
    
    self.mapView.hidden = FALSE;
    restaurantButton.hidden = FALSE;
    coffeshopButton.hidden =FALSE;
    mechanicButton.hidden = FALSE;
    favouriteButton.hidden = FALSE;
    [self.searchBar resignFirstResponder];
    
}

#pragma mark - Getting keyword from Search Bar

-(void)startSearch
{
    self.mapView.showsUserLocation = TRUE;
    _searchString = [[NSString alloc]init];
    _searchString = _searchBar.text;
    [[RequestHandler sharedRquest]getData:_searchString latitude:self.latitudeString longitude:self.longitudeString];
}

#pragma mark - Table View

-(void)reloadData               // Method to reload data and show data in table view
{
    [self.table reloadData];
}
    
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section     // Setting number of rows for table view
{
    sharedRequest = [RequestHandler sharedRquest];
    
    return [sharedRequest.dataArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath   // Method to place data in table view
{
    sharedRequest = [RequestHandler sharedRquest];
    
    static NSString *cellID = @"Cell Identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.favButton setImage:[UIImage imageNamed:@"favourite.png"] forState:UIControlStateNormal];
    self.favButton.frame = CGRectMake(5, 15, 20, 20);
    [self.favButton setTag:indexPath.row];
    [self.favButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 260, 50)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
    
    descriptionLabel.text = [[sharedRequest.dataArray objectAtIndex:indexPath.row]objectForKey:@"description"];
    [cell.contentView addSubview:self.favButton];
    [cell addSubview:descriptionLabel];
    return cell;
}

-(void)saveFromTable{
    
    NSLog(@"Entered");
    
    Favourites *fav = (Favourites *)[NSEntityDescription insertNewObjectForEntityForName:@"Favourites" inManagedObjectContext:_managedObjectContext];
    
    NSString *placeName = [sharedRequest.favArray valueForKey:@"name"];
    
    [fav setPlaceName:placeName];
    
    double latitude = [[[[sharedRequest.favArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
     NSString *str1 = [[NSString alloc]initWithFormat:@"%f",latitude ];
    double longitude = [[[[sharedRequest.favArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    NSString *str2 = [[NSString alloc]initWithFormat:@"%f",longitude ];
    [fav setPlaceLatitude:str1];
    [fav setPlaceLongitude:str2];
    
    NSError *error;
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"DataSavedSucessfully"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Added" message:@"Added To Favourites" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}


-(void)buttonPressed:(id)sender{

    UIButton *btn = (UIButton *)sender;
    self.indexOfButton = btn.tag;
    NSLog(@"Selected row is: %d",self.indexOfButton);
      
    NSMutableString *referenceToSave = [sharedRequest.referenceNameArray objectAtIndex:self.indexOfButton];
    
    [[RequestHandler sharedRquest]addToFavFromTable:referenceToSave];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath     // Method to process request when a cell is tapped
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MapDetails *mapDetails = [[MapDetails alloc]initWithNibName:@"MapDetails" bundle:nil];

    mapDetails.stringReference = [[sharedRequest.dataArray objectAtIndex:indexPath.row]objectForKey:@"reference"];
    
    NSLog(@"%@",mapDetails.stringReference);

    [self.navigationController pushViewController:mapDetails animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
