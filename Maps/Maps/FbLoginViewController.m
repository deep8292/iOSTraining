

#import "FbLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+AFNetworking.h"
@interface FbLoginViewController ()<FBLoginViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong,nonatomic) UILabel *userName;
@property (strong,nonatomic) UITableView *tableView;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@property (strong,nonatomic) NSArray *friendList;
@end

@implementation FbLoginViewController

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
    
    //User Name Label
    self.userName = [[UILabel alloc]initWithFrame:CGRectMake(99, 230, 161, 31)];
    self.userName.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.userName];
    
    //Setting up table view
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 270, 320, 280) style:UITableViewStylePlain];
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTable) name:@"FriendList" object:nil ];
    
    //Settting up Login View
    FBLoginView *loginview = [[FBLoginView alloc] init];
    loginview.frame = CGRectOffset(loginview.frame, 5, 5);
    loginview.delegate = self;
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
}



#pragma mark - Reloading Table
-(void)reloadTable{
    
    [self.tableView reloadData];
}


#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.friendList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
//    if (cell== nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    UIImageView *profilePhoto = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 50, 30)];

    NSString *str = [[self.friendList objectAtIndex:indexPath.row]objectForKey:@"pic_square"];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    UIImage *image = [UIImage imageWithData:data];
    
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
//            
//             
//            NSData *data = [NSData dataWithContentsOfURL:url];
//            UIImage *image = [UIImage imageWithData:data];
//    
//            dispatch_sync(dispatch_get_main_queue(), ^(void) {
//                
//                [profilePhoto setImage:image];
//    
//                [cell.contentView addSubview:profilePhoto];
//                
//                
//            });
//        });^(NSURLRequest *request,NSHTTPURLResponse *response, UIImage *image)
    
    [profilePhoto setImageWithURLRequest:requestURL placeholderImage:nil success:^(NSURLRequest *request,NSHTTPURLResponse *response, UIImage *image){
                
        [profilePhoto setImage:image];
        
    }failure:^(NSURLRequest *request,NSHTTPURLResponse *response, NSError *error){
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [cell.contentView addSubview:profilePhoto];
    
    [self setRoundedView:profilePhoto toDiameter:40.0f];
    [profilePhoto.layer setBorderWidth:2.0];
    profilePhoto.clipsToBounds = YES;
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 250, 44)];
    
    name.text = [[self.friendList objectAtIndex:indexPath.row]objectForKey:@"name"];
    
    [cell.contentView addSubview:name];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Method to fetch friend List
- (void)userFriendList {
    
    NSString *query =@"SELECT name, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend where uid1 = me())";
    
    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  // show result
                                  self.friendList = (NSArray *) [result objectForKey:@"data"];

                                  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
                                  
                                  NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                                  
                                 NSArray *a =[self.friendList sortedArrayUsingDescriptors: sortDescriptors];
                                  
                                  NSLog(@"%@",a);
                                 
                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"FriendList" object:nil];
                              }
                          }];
}

#pragma mark - Facebook Delegates
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.userName.text = [NSString stringWithFormat:@"%@",user.name];
    self.userName.autoresizingMask = UIViewAutoresizingFlexibleTopMargin| UIViewAutoresizingFlexibleHeight;
    self.profilePic.profileID = user.id;
    self.loggedInUser = user;
    [self setRoundedView:self.profilePic toDiameter:100.0f];
    [self.profilePic.layer setBorderWidth:3.0];
    [self userFriendList];
}

-(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}


- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    self.profilePic.profileID = nil;
    self.userName.text = nil;
    self.loggedInUser = nil;
    
    self.tableView = nil;
    [self.tableView reloadData];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
        NSLog(@"FBLoginView encountered an error=%@", error);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
