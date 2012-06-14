//
//  BRMapViewController.h
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BRMapViewController : UIViewController<CLLocationManagerDelegate, NSURLConnectionDataDelegate,MKMapViewDelegate>{
    CLLocationManager *locationManager;
    
}

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLable;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *alertLable;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSMutableData* responseData;
@property (weak,nonatomic) NSDate *lastTimestamp;
@property (weak,nonatomic) NSMutableArray *locationMeasurements;

@property (strong, nonatomic) IBOutlet MKMapView *mymap;


@property (nonatomic) NSInteger distance;
@property (nonatomic) NSInteger timeLeft;

@property (weak, nonatomic) IBOutlet UILabel *lableDuration;
@property (weak, nonatomic) IBOutlet UILabel *lableDistance;

////Annonations
@property (strong, nonatomic) MKPinAnnotationView* pinMe;
@property (strong, nonatomic) MKPinAnnotationView* pinTarget;


- (IBAction)StartClicked:(id)sender;


- (IBAction)StopClicked:(id)sender;
- (void)getDirectionsFromMAPSApi:(NSString* )sSource:(NSString*)sDestination;


@end
