#import "ViewController.h"
#import "RequestHandler.h"
#import "DetailViewController.h"
#import "MapViewController.h"
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
    
    //Table View and Search Delegates
    _table.delegate=self;
    _table.dataSource=self;
    _searchBar.delegate=self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadData) name:@"Doreload" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [_searchBar resignFirstResponder];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    self.latitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.latitude];
    self.longitudeString = [[NSMutableString alloc]initWithFormat:@"%f",newLocation.coordinate.longitude];
    
}

#pragma mark - Search Bar

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    _table.scrollEnabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self startSearch];
    _table.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[RequestHandler sharedRquest]showAllData:sharedRequest.referenceNameArray];
    
    [_searchBar resignFirstResponder];
    
    DetailViewController *details = [[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
    
    [self.navigationController pushViewController:details animated:YES];
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
