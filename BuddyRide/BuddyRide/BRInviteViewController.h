//
//  BRInviteViewController.h
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import "BRViewControllerWithFacebook.h"
#import "FBRequest.h"

@interface BRInviteViewController : BRViewControllerWithFacebook<UITableViewDataSource, UITableViewDelegate, FBRequestDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
