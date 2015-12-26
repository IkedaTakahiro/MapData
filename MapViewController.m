//
//  MapViewController.m
//  MapData
//
//  Created by 池田享浩 on 2015/12/17.
//  Copyright (c) 2015年 takahiro ikeda. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "DataViewController.h"


@interface MapViewController ()  <MKMapViewDelegate, CLLocationManagerDelegate>

// ロケーションマネージャー
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSMutableArray *annotationArray;

// マップキット
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// ボタン
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *dataButton;

- (IBAction)addButtonAction:(id)sender;
- (IBAction)dataButtonAction:(id)sender;

@end

//オリジナル機能追加
@interface MapViewController(){
    long count;
}
@end

@implementation MapViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // ロケーションマネージャーを作成
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    
    
    // 取得頻度（指定したメートル移動したら再取得する）
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //調査内容　desiredAccuracy(測定の精度を指定する) = kCLLocationAccuracyNearestTenMeters（10m）
    
    // 5m移動するごとに取得
    self.locationManager.distanceFilter = 5;
    //調査内容　distanceFilter (位置情報取得間隔)
    
    // アプリの使用中のみ位置情報を取得
    [self.locationManager requestWhenInUseAuthorization];
    //調査内容 requestWhenInUseAuthorization (使用中のみ使用許可)
    //requestAlwaysAuthorization(常に使用)
    
     self.isLocation = NO;
    
    // 位置情報取得開始
    [self.locationManager startUpdatingLocation];
    //調査内容　startUpdatingLocation GPS使用開始
    
    // 地図の機能を有効化
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.mapType = MKMapTypeSatellite;
    //調査内容　MKUserTrackingModeFollow　ユーザーの現在位置に応じてマップを更新する。
    
     NSLog(@"viewdidload呼び出し");
    
    NSUserDefaults *kiroku = [NSUserDefaults standardUserDefaults];  // 取得
    count = [kiroku integerForKey:@"key"];
    
    if (count == 1){
        
    }else{
        count = 0;
    };
    
    
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //調査内容　上記が呼び出し方
    //調査内容viewDidLoad：インスタンス化された直後（初回に一度のみ）
    //調査内容viewWillAppear：画面が表示される直前
    //調査内容viewDidAppear：画面が表示された直後
    
    NSLog(@"viewWillAppear呼び出し");

    // 初期情報の取得
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    //調査内容　NSUserDefaultsの取得
    NSMutableData *data = [nd objectForKey:@"annotationData"];
    //調査内容　id型（どんな型でもOKとういうこと）としてデータを呼び込む
    
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //調査内容　NSKeyedUnarchiver　データの呼び込み
    self.annotationArray = [[decoder decodeObjectForKey:@"annotation"] mutableCopy];
    //
    
    [decoder finishDecoding];
    //デコードの終了
    
    if (self.isLocation) {
        //YES NOでif判断
        // 地図の中心座標に現在地を設定
        CLLocationCoordinate2D co;
        //調査内容 CLLocationCoordinate2D地図の中心座標
        co.latitude = self.latitude; // 経度
        co.longitude = self.longitude; // 緯度
       
        
        self.mapView.centerCoordinate = co;
        
        // 表示倍率の設定
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
        [self.mapView setRegion:region animated:YES];
        //調査内容　animatedは、画面の切り替え方
    }
    
    // 画面が表示される時、ピンと経路を消しておく
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    //調査内容　removeAnnotationsは、ピンを削除。removeOverlaysは、線などの地図上に乗っているものを削除
    
    // 保持されているピンがなかった場合などには配列を初期化しておく
    if (self.annotationArray == nil) {
        self.annotationArray = [NSMutableArray arrayWithCapacity:0];
        NSLog(@"MapViewController annotationArrayが空のときによびだされる");
    }
    
    
    //オリジナル機能　初期有名どころデータを一度のみ読み込む
    switch (count) {
        case 1:
            NSLog(@"initialize化呼び出しなし");
            break;
            
        default:
            [self initialize];
            count = 1;
            NSLog(@"initialize化呼び出し");
            break;
    }
    
    NSUserDefaults *kiroku = [NSUserDefaults standardUserDefaults];
    [kiroku setInteger:1 forKey:@"key"];
   //ここまで
    
    // 配列に保持されたピンを取得しマップ上に表示
    for (CustomAnnotation *annotation in self.annotationArray) {
        //調査内容for(取り出す変数の型 取り出す変数名 in コレクションクラス)
        //　例for(NSString *str in array)
        if (self.annotationArray == nil) {
            NSLog(@"MapViewController initialize後　for分の中でannotationArrayが空のときによびだされる");
        }else{
            NSLog(@"MapViewController initialize後　for分の中でannotationArrayにデータあるときによびだされる");
        }

        [self.mapView addAnnotation:annotation];
        //addAnnotationでピンを追加する。addAnnotation: でアノテーションを追加すると mapView: viewForAnnotation: が呼び出されます。
        
    }
}

//オリジナル追加　初期有名どころデータ入り。
-(void)initialize{
    CustomAnnotation *annotation2;
    CLLocationCoordinate2D annoLocation2;
    annoLocation2.latitude  = 35.658581;
    annoLocation2.longitude = 139.745433;
    annotation2 =[[CustomAnnotation alloc] initWithCoordinate:annoLocation2];
    NSString *name1= @"東京タワー";
    NSString *subtitle2 = @"東京都港区芝公園４丁目２−８";
    annotation2.title = name1;
    annotation2.subtitle = subtitle2;
    //[self.mapView addAnnotation:annotation2];
    [self.annotationArray addObject:annotation2];//Arrayの最終行にobjectを挿入する
    
    CustomAnnotation *annotation3;
    CLLocationCoordinate2D annoLocation3;
    annoLocation3.latitude  = 35.710063;
    annoLocation3.longitude = 139.8107;
    annotation3 =[[CustomAnnotation alloc] initWithCoordinate:annoLocation3];
    NSString *name3= @"東京スカイツリー";
    NSString *subtitle3 = @"東京都墨田区押上1丁目1-13";
    annotation3.title = name3;
    annotation3.subtitle = subtitle3;
    //[self.mapView addAnnotation:annotation2];
    [self.annotationArray addObject:annotation3];//Arrayの最終行にobjectを挿入する
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSMutableData *data = [NSMutableData data];
    //空のdata作成
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //データのシリアライズ化の宣言
    [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
    //エンコードしている　foryKeyというキーワードで
    
    [encoder finishEncoding];
    [nd setObject:data forKey:@"annotationData"];
    [nd synchronize];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 位置情報が取得成功した場合にコールされる
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // 位置情報更新 引数３つ
    self.longitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    NSLog(@"test2");
    self.isLocation = YES;
   
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id)annotation {
//テキストに記述がない?? メソッド　引数２つ　返り値あり　
    //MKAnnotationViewは、独自に作成したアノテーションを使用したい場合に用いるクラスです。
    //標準で用意されているピンで構わない場合は、MKPinAnnotationViewクラスが用意されているのでそちらを使用します。
    // 現在地表示なら nil を返す
    
    
    if (annotation == mapView.userLocation) {
        NSLog(@"いつ実行されている？？");
        return nil;
    }
    
    MKAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    annotationView.canShowCallout = YES; //property コールアウトするしないの
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];//proprety
    
    annotationView.annotation = annotation;
    
    return annotationView;
}

- (IBAction)addButtonAction:(id)sender {
    
    // 地図の中心座標に現在地を設定
    CLLocationCoordinate2D co;
    co.latitude = self.latitude; // 経度
    co.longitude = self.longitude; // 緯度
    self.mapView.centerCoordinate = co;
    
    
    
    NSLog(@"test   %lf",(float)co.latitude);
    NSLog(@"test   %lf",(float)co.longitude);
    
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
    [self.mapView setRegion:region animated:YES];
    
    // リバースジオコーディング
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error) {
            NSLog(@"リバースジオコーディング失敗");
        } else {
            if(0 < [placemarks count]) {
                NSLog(@"test3");
                for(CLPlacemark *placemark in placemarks) {
                    
                    NSString *name = [NSString stringWithFormat:@"%@", placemark.name];
                    NSLog(@"test4 %@",name);
                    
                    NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@", placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare, placemark.subThoroughfare];
                    NSLog(@"test4 %@",address);
                    
                    CustomAnnotation *annotation;
                    CLLocationCoordinate2D annoLocation;
                    annoLocation.latitude  = self.latitude;
                    annoLocation.longitude = self.longitude;
                    annotation =[[CustomAnnotation alloc] initWithCoordinate:annoLocation];
                    annotation.title = name;
                    annotation.subtitle = address;
                    [self.mapView addAnnotation:annotation];
                    
                    [self.annotationArray addObject:annotation];
                    
                    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
                    NSMutableData *data = [NSMutableData data];
                    //空のdata作成
                    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    //データのシリアライズ化の宣言
                    [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
                    //エンコードしている　foryKeyというキーワードで
                    
                    [encoder finishEncoding];
                    [nd setObject:data forKey:@"annotationData"];
                    [nd synchronize];
                    
                }
            }
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //オリジナルで追加してみる。
    //self.latitude = newLocation.coordinate.laitude;
    //self.longitude = newLocation.coordinate.longitude;
    [self.locationManager startUpdatingLocation];
    //ここまで
    
    
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    CLLocationCoordinate2D toCoordinate = view.annotation.coordinate;
    
    // CLLocationCoordinate2D から MKPlacemark を生成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate addressDictionary:nil];
    
    // MKPlacemark から MKMapItem を生成
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    // MKMapItem をセットして MKDirectionsRequest を生成
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem;
    request.destination = toItem;
    request.requestsAlternateRoutes = YES;
    
    // MKDirectionsRequest から MKDirections を生成
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    // 経路検索を実行
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error) return;
         
         if ([response.routes count] > 0)
         {
             MKRoute *route = [response.routes objectAtIndex:0];
             
             // 地図上にルートを描画
             [self.mapView addOverlay:route.polyline];
         }
     }];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

// 地図上に描画するルートの色などを指定（これを実装しないと何も表示されない）
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.lineWidth = 5.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
    }
    else {
        return nil;
    }
}

- (IBAction)dataButtonAction:(id)sender {
    
    [self performSegueWithIdentifier:@"DataView" sender:self];
}

- (IBAction)exitFromDataView:(UIStoryboardSegue *)segue {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DataView"]) {
        
        //遷移テスト
        DataViewController *nextViewController = [segue destinationViewController];
        nextViewController.labelString = @"Label";
        NSLog(@"遷移test %@",nextViewController.labelString);
    }
}

@end
