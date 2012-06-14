//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright 2012 JoyTunes. All rights reserved.
//
#import "BRUser.h"


@implementation BRUser

@synthesize id = _id;
@synthesize name = _name;


- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.id = [dictionary objectForKey:@"id"];
        self.name = [dictionary objectForKey:@"name"];
    }

    return self;
}

@end