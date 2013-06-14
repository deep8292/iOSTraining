

#import <Foundation/Foundation.h>

@interface RequestHandler : NSObject

@property(strong,nonatomic)NSMutableString *requestString;
@property(strong,nonatomic)NSMutableArray *dataArray;
@property(strong,nonatomic)NSMutableArray *detailArray;
+(id)sharedRquest;
//-(void)getData:(NSString *)searchString;
-(void)getData:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng;
-(void)detailList:(NSString *)searchString latitude:(NSMutableString *)lat longitude:(NSMutableString*)lng;
@end
