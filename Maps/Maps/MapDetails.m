

#import "MapDetails.h"

@interface MapDetails ()
@property(strong,nonatomic)MKMapView *mapView;
@property (strong,nonatomic)UIActivityIndicatorView *spinner;
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
    
    self.navigationController.navigationBar.hidden = FALSE;
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 44, 320, 480);
    [self.view addSubview:_spinner];
    [self.spinner startAnimating];
    
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 0, 300, 250)];
    self.mapView.showsUserLocation = YES;
    
    self.mapView.delegate = self;
    
    self.groupedTableView.delegate = self;
    self.groupedTableView.dataSource = self;
    
    [[RequestHandler sharedRquest]detailList:self.stringReference];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showList" object:nil];
}


-(void)showOnMap{
    sharedRequest = [RequestHandler sharedRquest];
    
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];

    double latitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
    double longitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    
    CLLocationCoordinate2D coord =  {latitude,longitude};
    
    MKPointAnnotation *pin =[[MKPointAnnotation alloc]init];
    
    pin.coordinate = coord;
    pin.title = [sharedRequest.detailArray valueForKey:@"name" ];
    [self.mapView addAnnotation:pin];
    
    [self.groupedTableView reloadData];
    
    [self.spinner stopAnimating
     ];
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
            cell.textLabel.text = [NSString stringWithFormat:@"Name: %@",[sharedRequest.detailArray valueForKey:@"name" ]];
        }
        else if (indexPath.row == 1){
            [cell addSubview:self.mapView];
            
        }
    }
    else if (indexPath.section == 1)
    {
        NSString *str = [NSString stringWithFormat:@"%@",sharedRequest.ratings];
        
        if([str isEqualToString:@"(null)"]){
            cell.textLabel.text = [NSString stringWithFormat:@"Ratings: Not Rated yet"];
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
