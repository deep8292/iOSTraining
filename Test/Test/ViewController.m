//
//  ViewController.m
//  Test
//
//  Created by Deepak Khiwani on 13/07/13.
//  Copyright (c) 2013 Deepak Khiwani. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)twitter:(id)sender{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@""];
        [tweetSheet addImage:[UIImage imageNamed:@"PinkFloyd.jpg"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        }
    }

-(IBAction)facebook:(id)sender{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        NSURL *url = [NSURL URLWithString:@"http://www.youtube.com/watch?v=sPhhZg9v9NU"];
        [controller setInitialText:@""];
        [controller addImage:[UIImage imageNamed:@"FCB.jpg"]];
//        [controller addURL:url];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
