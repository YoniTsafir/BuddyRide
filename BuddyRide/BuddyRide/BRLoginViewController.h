//
//  BRFirstViewController.h
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBRequest.h"
#import "BRViewControllerWithFacebook.h"

@interface BRLoginViewController : BRViewControllerWithFacebook<FBRequestDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)login;

@end
