//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright 2012 JoyTunes. All rights reserved.
//
#import "BRViewControllerWithFacebook.h"
#import "Facebook.h"
#import "BRAppDelegate.h"


@implementation BRViewControllerWithFacebook

- (Facebook *)facebook {
    BRAppDelegate *delegate = (BRAppDelegate *)[[UIApplication sharedApplication] delegate];
    Facebook *facebook = delegate.facebook;
    return facebook;
}

@end