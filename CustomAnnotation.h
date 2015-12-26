//
//  CustomAnnotation.h
//  MapData
//
//  Created by 池田享浩 on 2015/12/19.
//  Copyright (c) 2015年 takahiro ikeda. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKAnnotationView <MKAnnotation, NSCoding>


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;


- (void)encodeWithCoder:(NSCoder *)aCoder;
//オブジェクトをアーカイブするときに呼ばれるメソッド encodeWithCoder

- (id)initWithCoder:(NSCoder *)aDecoder;
//アーカイブされたファイルからオブジェクトの状態を復元するときに呼ばれるメソッド　initWithCoder

@end
