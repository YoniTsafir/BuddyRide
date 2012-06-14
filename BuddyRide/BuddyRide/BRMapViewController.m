//
//  BRMapViewController.m
//  BuddyRide
//
//  Created by Yoni Tsafir on 14/6/12.
//  Copyright (c) 2012 YoniTsafir. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "BRMapViewController.h"
#import "AddressAnnotation.h"
#import "StackMob.h"

@interface BRMapViewController ()

@end

@implementation BRMapViewController

@synthesize startButton = _startButton;
@synthesize locationLable = _locationLable;
@synthesize stopButton= _stopButton;
@synthesize alertLable = _alertLable;
@synthesize locationManager = _locationManager;
@synthesize locationMeasurements = _locationMeasurements;
@synthesize mymap = _mymap;
@synthesize responseData = _responseData;
@synthesize distance = _distance;
@synthesize timeLeft = _timeLeft;
@synthesize lableDuration = _lableDuration;
@synthesize lableDistance = _lableDistance;
@synthesize lastTimestamp;
@synthesize pinMe = _pinSource;
@synthesize pinTarget =_pinTarget;


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
    [self.mymap setDelegate:self];
	// Do any additional setup after loading the view.
    self.alertLable.text = @"click start in order to get your location";
    
    self.locationManager = [[CLLocationManager alloc]init];
    
    [self.locationManager setDelegate:self];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;  
    
    //locationManager.distanceFilter
    
    [self.locationManager startUpdatingLocation];
    
    
    
    
    //otherLocation.latitude = latitudeValue;
    //otherLocation.longitude = longitudeValue;
    //addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:otherLocation];
    //[addAnnotation setTitle:@"destination"];
    //[map addAnnotation:addAnnotation];
    //self.pinMe = [[MKPinAnnotationColorRed alloc]ini, <#int#>)]
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDictionary *locationDict =
            [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:newLocation.coordinate.latitude],
                          @"lat", [NSNumber numberWithDouble:newLocation.coordinate.longitude], @"lon", nil];

    NSDictionary *updateLocationArgs = [NSDictionary dictionaryWithObjectsAndKeys:locationDict, @"location",
                                                     nil];
    [[StackMob stackmob] put:@"user" withId:[[NSUserDefaults standardUserDefaults] objectForKey:@"FBUserID"]
            andArguments:updateLocationArgs andCallback:^(BOOL success, id result) {
        NSLog(@"update location: success:%d, result:%@", success, result);
    }];

    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // store all of the measurements, just so we can see what kind of data we might receive
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mymap setRegion:region animated:YES];

    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:newLocation.coordinate];
    
    [addAnnotation setTitle:@"source"];
    [addAnnotation setPinColor:MKPinAnnotationColorGreen];
    [self.mymap addAnnotation:addAnnotation];
    
    
    [self.locationMeasurements addObject:newLocation];
    self.locationLable.text = [NSString stringWithFormat:@"%f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];

    // HACK HACK HACK!
    [self StartClicked:nil];
}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(error.code == kCLErrorDenied){
        self.alertLable.text = @"access deniend - dont have permissions";
    }
    if ((error.code == kCLErrorHeadingFailure) || (error.code ==  kCLErrorLocationUnknown )){
        
        self.alertLable.text = @"please try again in another palce";
        
    }
    [locationManager stopUpdatingLocation];
}

- (IBAction)StartClicked:(id)sender{
    
    
    if(self.locationMeasurements.count > 1){
        CLLocation* lastLocation = [self.locationMeasurements objectAtIndex:(self.locationMeasurements.count -1) ];
        NSString * cor = [NSString stringWithFormat:@"%f,%f", lastLocation.coordinate.latitude,
                                   lastLocation.coordinate.longitude];
        //TODO dont forget to get directions from current locaiton
        [self getDirectionsFromMAPSApi:@"batyam,il" dest:@"telaviv,il"];
    }
    else {
        self.alertLable.text = @"Syncing with GPS";
    }
    
    
}



- (IBAction)StopClicked:(id)sender{
    self.alertLable.text = @"stopped geting location";
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setStartButton:nil];
    [self setStopButton:nil];
    [self setAlertLable:nil];
    [self setLocationLable:nil];
    [self setMymap:nil];
    [self setLableDistance:nil];
    [self setLableDuration:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)getDirectionsFromMAPSApi:(NSString* )Source dest:(NSString*)sDestination
{
    
    
    NSMutableString *googleURL = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true&alternatives=true", Source, sDestination]];
    NSURL *url = [NSURL URLWithString:googleURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];        
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    self.responseData = [[NSMutableData alloc] init];
}

////////////////// CONNECTION FUNCTION
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // do something with the data object.
    [self.responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"%@", self.responseData);
    NSError *error = [[NSError alloc]init ];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableArray * polys = [self parseResponseWithDictionary:dictionary];
    NSMutableArray * coordinates= [[NSMutableArray alloc]init ];
    for (NSMutableString *poly in polys){
        [coordinates addObjectsFromArray:[self decodePolyLine:poly]];
    }
    
    CLLocationCoordinate2D coordinatesArray[coordinates.count];
    for (NSInteger index = 0; index < coordinates.count; index++) {
        CLLocation *location = [coordinates objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinatesArray[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinatesArray count:coordinates.count];
    
    [self.mymap addOverlay:polyLine];
    
    
    
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"error with page loading");
}

- (id)parseResponseWithDictionary:(NSDictionary *)dictResponse {
    if ([[dictResponse objectForKey:@"status"] isEqualToString:@"OK"]) {
        NSArray *listRoutes = (NSArray *)[dictResponse objectForKey:@"routes"];
        
        NSMutableString *result = nil;
        NSMutableArray *listPolylines = nil;
        //for (NSDictionary *dictRouteValues in listRoutes) {
        //we picking the first rout always
        NSDictionary *dictRouteValues = [listRoutes objectAtIndex:0];
        NSDictionary *dictlegs =[[dictRouteValues objectForKey:@"legs"] objectAtIndex:0];
        NSDictionary *distanceDic = [dictlegs objectForKey:@"distance"];
        NSDictionary *durationDic = [dictlegs objectForKey:@"duration"];
        
        self.distance = [[distanceDic objectForKey:@"value"] intValue];
        self.timeLeft = [[durationDic objectForKey:@"value"] intValue];
        self.lableDistance.text = [distanceDic objectForKey:@"text"];
        self.lableDuration.text = [durationDic objectForKey:@"text"];
        
        NSDictionary *dictPolyline = [dictRouteValues objectForKey:@"overview_polyline"];
        if (!result) {
            result = [[NSMutableString alloc] init];
        }
        [result appendString:[dictPolyline objectForKey:@"points"]];
        if (!listPolylines) {
            listPolylines = [[NSMutableArray alloc] init];
        }
        [listPolylines addObject:result];
        
        result = nil;
        
        NSLog(@"%@",result);
        return listPolylines;
    }
    else {
        NSString *error = @"No result found. Please check start and end location again!";
        return error;
    }
    return nil;
}
-(NSMutableArray *)decodePolyLine:(NSMutableString *)encoded {
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *listCoordinates = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        [listCoordinates addObject:[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]]];
        
    }
    
    return listCoordinates;
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 1.0;
    
    return polylineView;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

@end
