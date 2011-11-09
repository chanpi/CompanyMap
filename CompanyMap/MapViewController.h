//
//  MapViewController.h
//  CompanyMap
//
//  Created by  on 11/11/09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController<CLLocationManagerDelegate> {
    IBOutlet MKMapView* mapView_;
    CLLocationManager* locationManager_;
}

@property (nonatomic, retain) MKMapView* mapView_;

@end
