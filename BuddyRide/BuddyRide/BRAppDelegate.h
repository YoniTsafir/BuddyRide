//
//  BRAppDelegate.h
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 Yoni Tsafir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"


@class BRLoginViewController;
@class BRInviteViewController;


@interface BRAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) Facebook *facebook;

@property (nonatomic, strong) BRLoginViewController *loginViewController;
@property (nonatomic, strong) BRInviteViewController *inviteViewController;

@property (nonatomic, copy) NSString *pushToken;
@end
