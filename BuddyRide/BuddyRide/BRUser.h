//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright 2012 JoyTunes. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface BRUser : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;

@end