//
//  MapViewController.h
//  MapData
//
//  Created by 池田享浩 on 2015/12/17.
//  Copyright (c) 2015年 takahiro ikeda. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : ViewController

@property (assign, nonatomic) BOOL isLocation;

// 現在位置記録用
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (assign, nonatomic) CLLocationDegrees latitude;


@end