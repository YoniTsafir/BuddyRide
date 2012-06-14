//
//  BRInviteViewController.m
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import "BRInviteViewController.h"
#import "Facebook.h"
#import "BRUser.h"
#import "StackMob.h"

@interface BRInviteViewController()

@property (nonatomic, strong) NSMutableArray *facebookFriendsWithApp;
@property (nonatomic, strong) NSMutableArray *otherFacebookFriends;
@property (nonatomic, strong) NSMutableDictionary *usersById;

@end

@implementation BRInviteViewController

@synthesize tableView = _tableView;
@synthesize facebookFriendsWithApp = _facebookFriendsWithApp;
@synthesize otherFacebookFriends = _otherFacebookFriends;
@synthesize usersById = _usersById;


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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Friends with app installed";
    } else {
        return @"Other friends";
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FacebookFriend";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if (indexPath.section == 0) {
        cell.textLabel.text = [[self.facebookFriendsWithApp objectAtIndex:indexPath.row] name];
    } else {
        cell.textLabel.text = [[self.otherFacebookFriends objectAtIndex:indexPath.row] name];
    }

    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.facebookFriendsWithApp.count;
    } else {
        return self.otherFacebookFriends.count;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;

}


- (void)request:(FBRequest *)request didLoad:(id)result {
    NSArray *resultData = [result objectForKey:@"data"];
    NSLog(@"data:%@", resultData);
    self.facebookFriendsWithApp = [NSMutableArray array];
    self.otherFacebookFriends = [NSMutableArray array];
    self.usersById = [NSMutableDictionary dictionaryWithCapacity:[resultData count]];

    [resultData enumerateObjectsUsingBlock:^(id friend, NSUInteger index, BOOL *stop) {
        BRUser *user = [[BRUser alloc] initWithDictionary:friend];
        [self.usersById setObject:user forKey:user.id];

        [self.otherFacebookFriends addObject:user];
    }];

    StackMobQuery *query = [StackMobQuery query];
    [query field:@"username" mustBeOneOf:[self.usersById allKeys]];

    [[StackMob stackmob] get:@"user" withQuery:query andCallback:^(BOOL success, id stackMobResult) {
        for (NSDictionary *stackMobUser in stackMobResult) {
            BRUser *user = [self.usersById objectForKey:[stackMobUser objectForKey:@"username"]];
            [self.otherFacebookFriends removeObject:user];
            [self.facebookFriendsWithApp addObject:user];

            [self.tableView reloadData];
        }

    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BRUser *user;
    if (indexPath.section == 0) {
        user = [self.facebookFriendsWithApp objectAtIndex:indexPath.row];
    } else {
        user = [self.otherFacebookFriends objectAtIndex:indexPath.row];
    }

    [[StackMob stackmob]
            sendPushToUsersWithArguments:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],
                                                                                    @"badge", @"hello sam!", @"alert", nil]

            withUserIds:[NSArray arrayWithObject:user.id]
            andCallback:^(BOOL success, id result) {
                NSLog(@"sent push! success:%d, result:%@", success, result);
                // TODO:
            }];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
