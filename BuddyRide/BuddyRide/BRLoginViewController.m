//
//  BRFirstViewController.m
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRAppDelegate.h"
#import "Facebook.h"
#import "StackMob.h"

@interface BRLoginViewController()

@end

@implementation BRLoginViewController

@synthesize loginButton = _loginButton;


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

    [self.loginButton setImage:
     [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookNormal@2x.png"]
                 forState:UIControlStateNormal];
    [self.loginButton setImage:
     [UIImage imageNamed:@"FBConnect.bundle/images/LoginWithFacebookPressed@2x.png"]
                 forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
* Show the authorization dialog.
*/
- (IBAction)login {
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:[NSArray arrayWithObject:@"offline_access"]];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSString *facebookID = [result objectForKey:@"id"];

    [[NSUserDefaults standardUserDefaults] setObject:facebookID forKey:@"FBUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (facebookID != nil) {
        [[StackMob stackmob]
                registerWithFacebookToken:self.facebook.accessToken username:facebookID
                              andCallback:^(BOOL success, id stackMobResult) {
                                  BRAppDelegate *appDelegate = (BRAppDelegate *)[UIApplication
                                          sharedApplication].delegate;

                                  [[StackMob stackmob] registerForPushWithUser:facebookID
                                                                         token:appDelegate.pushToken
                                                                   andCallback:^(BOOL success, id result){
                                                                       NSLog(@"registered for push. user:%@, success:%d, result:%@",
                                                                             facebookID, success,
                                                                             result);
                                                                   }];

                                  // TODO: check success?
                                  [self.navigationController pushViewController:appDelegate.inviteViewController
                                                                       animated:YES];
                              }];

    }
}

@end
