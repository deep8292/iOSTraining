
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
    
    
    NSString *requestString = [[NSString alloc]init];
    requestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?input=%@&location=%@,%@&radius=500&zoom=14&sensor=false&key=AIzaSyCT7FpXT78LPum0d9YwGFDgUvCcOqCmsSg",searchString,lat,lng];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"URL: %@",requestURL);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        self.dataArray = [JSON objectForKey:@"results"];
//        NSLog(@"data arra: %@",self.dataArray);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Doreload" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
}

-(void)detailList:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng
{
    _detailArray = [[NSMutableArray alloc]init];
    
    NSString *requestString = [[NSString alloc]initWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=500&types=%@&sensor=false&key=AIzaSyCT7FpXT78LPum0d9YwGFDgUvCcOqCmsSg",lat,lng,searchString];
    
    NSURL *URL = [NSURL URLWithString:requestString];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:URL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *requestURL,NSHTTPURLResponse *response, id JSON){
        
        self.detailArray = [JSON objectForKey:@"result"];
        
        NSLog(@"%@",self.detailArray);
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showList" object:nil];
        
    }failure:^(NSURLRequest *requestURL,NSHTTPURLResponse *response,NSError *error, id JSON){
        
    }];
    
    [operation start];
}



@end
