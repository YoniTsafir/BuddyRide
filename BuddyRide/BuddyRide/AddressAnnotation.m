//
//  MapDir.m
//  MapsDirectionsPOC
//
//  Created by lior lev tov on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "AddressAnnotation.h"
#import <MapKit/MapKit.h>

@implementation AddressAnnotation
@synthesize coordinate = _coordinate;
@synthesize title= _title;
@synthesize subtitle = _subtitle;
@synthesize pinColor= _pinColor;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c{
    coordinate=c;
    return self;
}
@end