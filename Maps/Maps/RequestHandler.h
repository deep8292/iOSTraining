

#import <Foundation/Foundation.h>

@interface RequestHandler : NSObject

@property(strong,nonatomic)NSMutableString *requestString;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)NSMutableArray *referenceNameArray;
@property(strong,nonatomic)NSMutableArray *detailArray;
@property(strong,nonatomic)NSMutableArray *referenceArray;
@property(strong,nonatomic)NSMutableArray *name;
@property(strong,nonatomic)NSMutableArray *location;
@property(strong,nonatomic)NSString *ratings;

@property(strong,nonatomic)NSMutableArray *latArray;
@property(strong,nonatomic)NSMutableArray *lngArray;
@property(strong,nonatomic)NSMutableArray *resultArray;
@property(strong,nonatomic)NSMutableDictionary *reviewDictionary;

@property(strong,nonatomic)NSMutableArray *placeArray;
//@property(strong,nonatomic)NSMutableArray *restautrantsArray;
//@property(strong,nonatomic)NSMutableArray *coffeeShopsArray;
//@property(strong,nonatomic)NSMutableArray *mechanicsArray;;

+(id)sharedRquest;

-(void)getData:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng;
-(void)detailList:(NSString *)searchString;
-(void)showAllData:(NSMutableArray *)array;

-(void)placeResults:(NSMutableString*)lat longitude:(NSMutableString*)lng searchKeyword:(NSString *)search;

//-(void)restaurantsResults:(NSMutableString*)lat longitude:(NSMutableString*)lng;
//-(void)coffeeShopsResults:(NSMutableString*)lat longitude:(NSMutableString*)lng;
//-(void)mechanicsData:(NSMutableString*)lat longitude:(NSMutableString*)lng;

@end
