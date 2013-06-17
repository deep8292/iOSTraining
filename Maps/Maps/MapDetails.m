

#import "MapDetails.h"

@interface MapDetails ()
@property(strong,nonatomic)MKMapView *mapView;

@end

@implementation MapDetails

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 0, 300, 250)];
    
    self.mapView.delegate = self;
    
    self.groupedTableView.delegate = self;
    self.groupedTableView.dataSource = self;
    
    [self showOnMap];
}


-(void)showOnMap{
    sharedRequest = [RequestHandler sharedRquest];
    
    CLLocationCoordinate2D coord =  {self.latitude,self.longitude};
    
    MKPointAnnotation *pin =[[MKPointAnnotation alloc]init];
    
    pin.coordinate = coord;
    pin.title = self.nameString;
    [self.mapView addAnnotation:pin];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    sharedRequest = [RequestHandler sharedRquest];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0)
    {
        return @"Details";
    }
    else{
        return @"Reviews";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        return 2;
    }
    else if (section == 1){
        return 1;
    }
    else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        else if (indexPath.row == 1){
            return 250.0f;
        }
        else{
            return 0;
        }
    }
    else if (indexPath.section == 1){
        return 44.0f;
    }
    else{return 0;}
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID =@"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"Name: %@",self.nameString];
        }
        else if (indexPath.row == 1){
            [cell addSubview:self.mapView];
            
        }
    }
    else if (indexPath.section == 1)
    {
        NSString *str = [NSString stringWithFormat:@"%@",sharedRequest.ratings];
        
        if([str isEqual: @""]){
            cell.textLabel.text = [NSString stringWithFormat:@"Ratings: 0"];
        }
        else{
             cell.textLabel.text = [NSString stringWithFormat:@"Ratings: %@",sharedRequest.ratings];
        }
    }
    else{
        
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
