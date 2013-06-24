

#import "MapDetails.h"

@interface MapDetails ()
@property(strong,nonatomic)MKMapView *mapView;

@property(strong,nonatomic)NSMutableArray *nameArray;
@property(strong,nonatomic)NSMutableArray *arrayOfReviews;
@property(strong,nonatomic)NSMutableArray *timeStamp;

@property(strong,nonatomic)NSMutableString *name;
@property(strong,nonatomic)NSMutableString *reviews;
@property(strong,nonatomic)UIActivityIndicatorView *spinner;
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
    
    //Setting Spinner View
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.frame = CGRectMake(0, 44, 320, 480);
    [self.view addSubview:_spinner];
    [self.spinner startAnimating];
    
    //Setting Map
    self.mapView = [[MKMapView alloc]initWithFrame:CGRectMake(10, 0, 300, 250)];
    self.mapView.delegate = self;
    
    //Setting Table View
    self.groupedTableView.delegate = self;
    self.groupedTableView.dataSource = self;
    
    //Check whether place is selected from map or table view
    if (self.stringReference != nil) {
        [[RequestHandler sharedRquest]detailList:self.stringReference];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showOnMap) name:@"showList" object:nil];
    }
    else{
        [self showDataFromPin];
    }
    
}

-(void)showDataFromPin      // Method to show data when coming from map
{

    double lat = self.locationLatitude;
    double lng = self.locationLongitude;
    
    self.name = [NSString stringWithFormat:@"%@",self.nameString];
    
    
    
    self.nameArray = [self.reviewArray valueForKey:@"author_name"];
    
    self.arrayOfReviews = [self.reviewArray valueForKey:@"text"];
    self.timeStamp = [self.reviewArray valueForKey:@"time"];
    
    CLLocationCoordinate2D coord = {lat,lng};
    
    MKPointAnnotation *pin =[[MKPointAnnotation alloc]init];
    
    pin.coordinate = coord;
    pin.title = self.name;
    [self.mapView addAnnotation:pin];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03f, 0.03f);
    
    MKCoordinateRegion region;
    
    region.center = coord;
    region.span =span;
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [self.groupedTableView reloadData];

    [self.spinner stopAnimating];
}


-(void)showOnMap        // Method to show data when coming from table view
{
    sharedRequest = [RequestHandler sharedRquest];
    
   
    double latitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"]doubleValue];
    double longitude = [[[[sharedRequest.detailArray valueForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"]doubleValue];
    
    self.name  = [sharedRequest.detailArray valueForKey:@"name" ];
    
    self.reviewArray = [sharedRequest.detailArray valueForKey:@"reviews"];
    
    self.nameArray = [self.reviewArray valueForKey:@"author_name"];
    
    self.arrayOfReviews = [self.reviewArray valueForKey:@"text"];
    
   self.timeStamp = [self.reviewArray valueForKey:@"time"];
    
    
    CLLocationCoordinate2D coord =  {latitude,longitude};
    
    MKPointAnnotation *pin =[[MKPointAnnotation alloc]init];
    
    pin.coordinate = coord;
    pin.title = [sharedRequest.detailArray valueForKey:@"name" ];
    [self.mapView addAnnotation:pin];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03f, 0.03f);
    
    MKCoordinateRegion region;
    
    region.center = coord;
    region.span =span;
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
       
    [self.groupedTableView reloadData];
    
    [self.spinner stopAnimating];
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
        if ([self.reviewArray count]>0) {
            return [self.reviewArray count];
        }
        else{
            return 1;
        }
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
        if ([self.reviewArray count]>0) {
            return 100.0f;}
        else{
            return 44.0f;
            
        }
    }
    else{return 0;}
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID =@"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = self.name;
        }
        else if (indexPath.row == 1){
            [cell addSubview:self.mapView];
            
        }
    }
    else{
        
        if ([self.reviewArray count]>0) {
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, -17, 120, 50)];
            nameLabel.font = [UIFont systemFontOfSize:10.0f];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.text = [self.nameArray objectAtIndex:indexPath.row];
            
            [cell addSubview:nameLabel];
            
            UILabel *review = [[UILabel alloc]initWithFrame:CGRectMake(13,0 , 250, 100)];
            review.font = [UIFont systemFontOfSize:8.0f];
            review.backgroundColor = [UIColor clearColor];
            NSString *str = [[NSString alloc]initWithFormat:@"%@",[self.arrayOfReviews objectAtIndex:indexPath.row]];
            str = [str stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
            review.text = str;
            review.numberOfLines =6;
            [cell addSubview:review];
            
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 90, 100, 10)];
            timeLabel.backgroundColor = [UIColor clearColor];
            timeLabel.font = [UIFont italicSystemFontOfSize:8.0f];
            timeLabel.textColor = [UIColor grayColor];
            double timeStampVal = [[self.timeStamp objectAtIndex:indexPath.row]doubleValue];
            NSTimeInterval timestamp = (NSTimeInterval)timeStampVal;
            NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
            timeLabel.text = [NSString stringWithFormat:@"%@",updatetimestamp];
            [cell addSubview:timeLabel];

        }
        else{
            cell.textLabel.text = @"No Reviews yet";
        }
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
