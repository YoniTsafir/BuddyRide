//
//  MapDir.h
//  MapsDirectionsPOC
//
//  Created by lior lev tov on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface AddressAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;

}
@property (nonatomic,weak) NSString *title;
@property (nonatomic,weak) NSString *subtitle;
@property (nonatomic) MKPinAnnotationColor pinColor;
-(id)initWithCoordinate:(CLLocationCoordinate2D)c;
@end