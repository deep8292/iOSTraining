
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

-(void)getData:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng
{
    _dataArray = [[NSMutableArray alloc]init];
    
    self.referenceNameArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]init];
    
    requestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@,%@&&radius=33000&language=fr&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",searchString,lat,lng];

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

-(void)detailList:(NSString *)searchString
{
    _detailArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",searchString];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
//    NSLog(@"%@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.detailArray = [JSON objectForKey:@"result"];
        
        self.ratings = [[JSON objectForKey:@"result"]objectForKey:@"rating"];
        
        NSLog(@"%@",self.detailArray);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showList" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
         NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

-(void)showAllData:(NSMutableArray *)array{
    
    self.referenceArray = [[NSMutableArray alloc]init];
    
    self.name = [[NSMutableArray alloc]init];;
    self.location = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[self.referenceNameArray count]; i++)
    {
        NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",[self.referenceNameArray objectAtIndex:i]];
        
        NSURL *URL = [NSURL URLWithString:requestString];
        NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
            
            NSString *name = [[JSON objectForKey:@"result"]objectForKey:@"name"];
            
            [self.name addObject:name];
            
            self.location = [[[JSON objectForKey:@"result"]objectForKey:@"geometry"]objectForKey:@"location"];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showAllData" object:nil];
                        
        }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
          NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);   
        }];
        
        [operation start];
    }
  
    
}


-(void)restaurantsResults:(NSMutableString*)lat longitude:(NSMutableString*)lng{
    
    self.restautrantsArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=500&types=restaurant&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",lat,lng];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.restautrantsArray = [JSON objectForKey:@"results"];
        
        NSLog(@"Restaurant:%@",self.restautrantsArray);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Restaurant" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

-(void)coffeeShopsResults:(NSMutableString*)lat longitude:(NSMutableString*)lng{
    
    self.coffeeShopsArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants&location=%@,%@&radius=33000&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",lat,lng];
    
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Request String:%@",requestString);
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.coffeeShopsArray = [JSON objectForKey:@"results"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CoffeeShop" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

-(void)mechanicsData:(NSMutableString*)lat longitude:(NSMutableString*)lng{
    
    self.mechanicsArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=mechanics&location=%@,%@&radius=33000&sensor=true&key=AIzaSyDf7hO-iFifAJAmc3v_2pKAgVqeBVR3rsg",lat,lng];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.mechanicsArray = [JSON objectForKey:@"results"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Mechanics" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}


@end
