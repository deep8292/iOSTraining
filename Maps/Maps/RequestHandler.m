
#import "RequestHandler.h"
#import "AFNetworking.h"
#import "ViewController.h"
@implementation RequestHandler

+(id)sharedRquest
{
    static RequestHandler *sharedMyRequest;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyRequest = [[self alloc]init];
    });
    return sharedMyRequest;
}

#pragma mark - AutoComplete Request
-(void)getData:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng
{
    _dataArray = [[NSMutableArray alloc]init];
    
    self.referenceNameArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]init];
    
    requestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@,%@&&radius=33000&language=fr&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",searchString,lat,lng];

    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"Request URL: %@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.dataArray = [JSON objectForKey:@"predictions"];
        
        self.referenceNameArray = [self.dataArray valueForKey:@"reference"];
    
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Doreload" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

#pragma mark - Request for Details of One Place
-(void)detailList:(NSString *)searchString
{
    _detailArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",searchString];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
//    NSLog(@"%@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.detailArray = [JSON objectForKey:@"result"];
        
        self.ratings = [[JSON objectForKey:@"result"]objectForKey:@"rating"];
        
//        NSLog(@"%@",self.detailArray);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showList" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
         NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

-(void)addToFavFromTable:(NSString *)searchString
{
    _favArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",searchString];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    //    NSLog(@"%@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.favArray = [JSON objectForKey:@"result"];
        
//        self.ratings = [[JSON objectForKey:@"result"]objectForKey:@"rating"];
        
        //        NSLog(@"%@",self.detailArray);
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"newList" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}


#pragma mark - Request to place all the places on map 
-(void)showAllData:(NSMutableArray *)array{
    
    self.referenceArray = [[NSMutableArray alloc]init];
    
    self.name = [[NSMutableArray alloc]init];;
//    self.location = [[NSMutableArray alloc]init];
    
    self.latArray = [[NSMutableArray alloc]init];
    self.lngArray = [[NSMutableArray alloc]init];
    
    self.resultArray = [[NSMutableArray alloc]init];
    
    self.reviewDictionary = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i<[self.referenceNameArray count]; i++)
    {
        NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",[self.referenceNameArray objectAtIndex:i]];
        
        NSURL *URL = [NSURL URLWithString:requestString];
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
        
//        NSLog(@"Show Data : %@",requestURL);
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
            
            self.resultArray = [[JSON objectForKey:@"result"]objectForKey:@"reviews"];
            
            NSString *name = [[JSON objectForKey:@"result"]objectForKey:@"name"];
            
            [self.name addObject:name];
           
            //Setting Dictionary for reviews for every Place Name
            [self.reviewDictionary setObject:self.resultArray forKey:name];
                        
            self.location = [[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"];
            
            NSMutableString *latitude = [[[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
            
            NSMutableString *longitude = [[[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
        
            [self.latArray addObject:latitude]; // array to keep all the latitudes of the searched place
            [self.lngArray addObject:longitude];// array to keep all the longitudes of the searched place
                        
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showAllData" object:nil];
                        
        }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
          NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);   
        }];
        
        [operation start];
    }
}

#pragma mark - Request process on click of buttons
-(void)placeResults:(NSMutableString*)lat longitude:(NSMutableString*)lng searchKeyword:(NSString *)search{
    
    self.placeArray = [[NSMutableArray alloc]init];
    
    self.placeLatAray= [[NSMutableArray alloc]init];
    self.placeLngAray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%@,%@&radius=33000&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",search,lat,lng];
    
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];

    NSLog(@"Request URL:%@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.placeArray = [JSON objectForKey:@"results"];

        self.name = [self.placeArray valueForKey:@"name"];
        
        self.location = [self.placeArray valueForKey:@"geometry"];
    
        for (int i = 0; i<[self.placeArray count]; i++) {
            NSMutableDictionary *dict = [[[self.placeArray objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location"];
            NSMutableString *latitudeString = [dict objectForKey:@"lat"];
            NSMutableString *longitudeString = [dict objectForKey:@"lng"];
            [_placeLatAray addObject:latitudeString];
            [_placeLngAray addObject:longitudeString];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showPlaces" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

@end
