//
//  DataViewController.m
//  MapData
//
//  Created by 池田享浩 on 2015/12/17.
//  Copyright (c) 2015年 takahiro ikeda. All rights reserved.
//

#import "DataViewController.h"
#import "CustomAnnotation.h"
#import "MapViewController.h"

@interface DataViewController() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *backbutton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

// 位置記録用
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (assign, nonatomic) CLLocationDegrees latitude;

- (IBAction)backButtonAction:(id)sender;
- (IBAction)editButtonAction:(id)sender;

@property (strong, nonatomic) NSMutableArray *annotationArray;

@end

@implementation DataViewController

- (void) viewDidLoad {
      
  
    NSString *tameshi = self.labelString;
    NSLog(@"DataViewController 遷移test %@",tameshi);
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSMutableData *data = [nd objectForKey:@"annotationData"];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.annotationArray = [[decoder decodeObjectForKey:@"annotation"] mutableCopy];
    [decoder finishDecoding];
    NSLog(@"ここは出力される");
    
    if (self.annotationArray == nil) {
        self.annotationArray = [NSMutableArray arrayWithCapacity:0];
        NSLog(@"ここは出力されてるとannotationArrayが空");
    }
    
    NSInteger count2 = [self.annotationArray count];
    NSLog(@"データ数　%ld",(long)count2);
    
   
    self.tableView.dataSource = self;   // z numberOfRowsInSectionデリゲートなどを呼び出せるようにするため
    self.tableView.delegate = self;  // didSelectRowAtIndexPathデリゲートを呼び出せるようにするため
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
 
    return [self.annotationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    cell.textLabel.text = [self.annotationArray[indexPath.row] title];
   
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.latitude = [self.annotationArray[indexPath.row] coordinate].latitude;
    self.longitude = [self.annotationArray[indexPath.row] coordinate].longitude;
    
    [self performSegueWithIdentifier:@"ExitDataView" sender:self];
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButtonAction:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.annotationArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
        [encoder finishEncoding];
        [nd setObject:data forKey:@"annotationData"];
        [nd synchronize];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ExitDataView"]) {
        
        MapViewController *prevViewController = [segue destinationViewController];
        prevViewController.isLocation = YES;
        prevViewController.latitude = self.latitude;
        prevViewController.longitude = self.longitude;
    }
}

@end
