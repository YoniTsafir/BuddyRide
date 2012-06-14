//
//  BRAppDelegate.m
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 Yoni Tsafir. All rights reserved.
//

#import "BRAppDelegate.h"
#import "BRLoginViewController.h"
#import "FBConnect.h"
#import "StackMob.h"
#import "BRInviteViewController.h"


static NSString const *kBuddyRideFBAppID = @"406598512715014";


@interface BRAppDelegate()

@property (nonatomic, strong, readwrite) Facebook *facebook;

@end


@implementation BRAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize loginViewController = _loginViewController;
@synthesize inviteViewController = _inviteViewController;
@synthesize pushToken = _pushToken;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.facebook =
            [[Facebook alloc]
                    initWithAppId:(NSString *)kBuddyRideFBAppID andDelegate:self];

    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }


    self.inviteViewController = [[BRInviteViewController alloc]
            initWithNibName:@"BRInviteViewController" bundle:nil];

    UINavigationController *navCon;

    if ([self.facebook isSessionValid]) {
        [[StackMob stackmob] loginWithFacebookToken:self.facebook.accessToken andCallback:^(BOOL success, id result) {
            // TODO check success?
        }];
        navCon = [[UINavigationController alloc]
                initWithRootViewController:self.inviteViewController];

    } else {
        self.loginViewController = [[BRLoginViewController alloc]
                                                           initWithNibName:@"BRLoginViewController"
                                                                    bundle:nil];

        navCon = [[UINavigationController alloc]
                initWithRootViewController:self.loginViewController];
    }
    navCon.navigationBarHidden = YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navCon;
    [self.window makeKeyAndVisible];
    
    NSLog(@"Registering for push notifications...");    
    [[UIApplication sharedApplication] 
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | 
      UIRemoteNotificationTypeBadge | 
      UIRemoteNotificationTypeSound)];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    [self.facebook extendAccessTokenIfNeeded];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"Device Token=%@", deviceToken);

    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [[token componentsSeparatedByString:@" "] componentsJoinedByString:@""];
    self.pushToken = token;

    NSString *facebookId = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBUserID"];

    if (facebookId != nil) {
        [[StackMob stackmob] registerForPushWithUser:facebookId
                                               token:token
                                         andCallback:^(BOOL success, id result){
                                             NSLog(@"registered for push. user:%@, success:%d, result:%@",
                                                   facebookId, success, result);
                                         }];
    } else {
        NSLog(@"No logged in user!");
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err { 
    
    NSLog(@"Error: %@", err);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}


- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.facebook.accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:self.facebook.expirationDate forKey:@"FBExpirationDateKey"];
    [defaults synchronize];

    // get information about the currently logged in user
    [self.facebook requestWithGraphPath:@"me" andDelegate:self.loginViewController];
}

- (void)fbDidNotLogin:(BOOL)cancelled {

}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {

}

- (void)fbDidLogout {

}

- (void)fbSessionInvalidated {

}

@end
