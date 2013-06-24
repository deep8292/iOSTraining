
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
    
//    NSLog(@"Request URL: %@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.dataArray = [JSON objectForKey:@"predictions"];
        
        self.referenceNameArray = [self.dataArray valueForKey:@"reference"];
        
        NSLog(@"Reference Name array: %d",[self.referenceNameArray count]);
        
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

#pragma mark - Request to place all the places on map 
-(void)showAllData:(NSMutableArray *)array{
    
    self.referenceArray = [[NSMutableArray alloc]init];
    
    self.name = [[NSMutableArray alloc]init];;
    self.location = [[NSMutableArray alloc]init];
    
    self.latArray = [[NSMutableArray alloc]init];
    self.lngArray = [[NSMutableArray alloc]init];
    
    self.resultArray = [[NSMutableArray alloc]init];
    
    self.reviewDictionary = [[NSMutableDictionary alloc]init];
    
//    NSMutableArray  *arr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[self.referenceNameArray count]; i++)
    {
        NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",[self.referenceNameArray objectAtIndex:i]];
        
        NSURL *URL = [NSURL URLWithString:requestString];
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
            
            self.resultArray = [[JSON objectForKey:@"result"]objectForKey:@"reviews"];
            
//            NSLog(@"%@",self.resultArray);
            
            NSString *name = [[JSON objectForKey:@"result"]objectForKey:@"name"];
            
            [self.name addObject:name];
           
            //Setting Dictionary for reviews for every Place Name
            [self.reviewDictionary setObject:self.resultArray forKey:name];
            
            NSLog(@"%@",self.reviewDictionary);
            
//            NSLog(@"new dict: %@",dict);
            
//            NSLog(@"Name array: %@",self.name);
            
            self.location = [[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"];
            
            NSMutableString *latitude = [[[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lat"];
            
            NSMutableString *longitude = [[[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"]objectForKey:@"lng"];
        
            [self.latArray addObject:latitude]; // array to keep all the latitudes of the searched place
            [self.lngArray addObject:longitude];// array to keep all the longitudes of the searched place
            
//            NSLog(@"Latitude array:%@",self.latArray);
//            NSLog(@"Longitude array:%@",self.lngArray);
            
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
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%@,%@&radius=33000&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",search,lat,lng];
    
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];

    NSLog(@"Request URL:%@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.placeArray = [JSON objectForKey:@"results"];
        
        NSLog(@"Restaurant:%@",self.placeArray);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showPlaces" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

//-(void)coffeeShopsResults:(NSMutableString*)lat longitude:(NSMutableString*)lng{
//    
//    self.coffeeShopsArray = [[NSMutableArray alloc]init];
//    
//    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=coffee shops&location=%@,%@&radius=33000&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",lat,lng];
//    
//    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSLog(@"Request String:%@",requestString);
//    
//    NSURL *URL = [NSURL URLWithString:requestString];
//    
//    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
//    
//     NSLog(@"Coffee Shops %@",requestURL);
//    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
//        
//        self.coffeeShopsArray = [JSON objectForKey:@"results"];
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"CoffeeShop" object:nil];
//        
//    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
//        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
//    }];
//    
//    [operation start];
//}
//
//-(void)mechanicsData:(NSMutableString*)lat longitude:(NSMutableString*)lng{
//    
//    self.mechanicsArray = [[NSMutableArray alloc]init];
//    
//    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=mechanics&location=%@,%@&radius=33000&sensor=true&key=AIzaSyAf28q6kNqs0jPjPnVf-MoMCTJJB7qFBQ0",lat,lng];
//    
//    NSURL *URL = [NSURL URLWithString:requestString];
//    
//    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
//    
//     NSLog(@"Mechanics %@",requestURL);
//    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
//        
//        self.mechanicsArray = [JSON objectForKey:@"results"];
//        
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"Mechanics" object:nil];
//        
//    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
//        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
//    }];
//    
//    [operation start];
//}


@end
