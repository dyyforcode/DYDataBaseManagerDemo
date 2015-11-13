//
//  ViewController.m
//  DYDataBaseManager
//
//  Created by qianfeng on 15/11/12.
//  Copyright © 2015年 myOwn. All rights reserved.
//

#import "ViewController.h"

#import "DYDataBaseManager.h"

@interface ViewController ()

@property (nonatomic) DYDataBaseManager * dyDataBaseManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dyDataBaseManager = [DYDataBaseManager shareManager];
}
- (IBAction)createButtonClicked:(UIButton *)sender {
    if([self.dyDataBaseManager excuteSomeMainSQL:@"CREATE TABLE IF NOT EXISTS attentionHouse_info (id TEXT PRIMARY KEY,name TEXT,address TEXT)"]){
        NSLog(@"创建成功");
    }else{
        NSLog(@"创建失败");
    }
}

- (IBAction)insertButtonOneClicked:(UIButton *)sender {
    if([self.dyDataBaseManager insertIntoTable:@"INSERT INTO attentionHouse_info values(?,?,?)" info:@[@"11111",@"首胜",@"宝盛里"]]){
        NSLog(@"插入one成功");
    }else{
        NSLog(@"插入one失败");
    }
}
- (IBAction)insertButtonTwoClicked:(UIButton *)sender {
    if([self.dyDataBaseManager insertIntoTable:@"INSERT INTO attentionHouse_info values('22222','美景','永泰')"]){
        NSLog(@"插入two成功");
    }else{
        NSLog(@"插入two失败");
    }
}

- (IBAction)deleteButtonOneClicked:(UIButton *)sender {
    if([self.dyDataBaseManager removeATable:@"DELETE FROM attentionHouse_info where id = ?" info:@"11111"]){
        NSLog(@"删除one成功");
    }else{
        NSLog(@"删除one失败");
    }
    
}
- (IBAction)deleteButtonTwoClicked:(UIButton *)sender {
    if([self.dyDataBaseManager removeATable:@"DELETE FROM attentionHouse_info where id = '22222'"]){
        NSLog(@"删除two成功");
    }else{
        NSLog(@"删除two失败");
    }
}

- (IBAction)seleceButtonOneClicked:(UIButton *)sender {
    NSArray * array = [self.dyDataBaseManager selectFromTable:@"select * from attentionHouse_info" propertyArray:@[@"id",@"name",@"address"]];
    for(NSDictionary * dic in array){
        NSLog(@"%@",dic);
    }
}
- (IBAction)selectButtonTwoClicked:(UIButton *)sender {
    NSArray * array = [self.dyDataBaseManager selectFromTable:@"select * from attentionHouse_info where id = ?" withPropertyName:@[@"11111"] propertyArray:@[@"id",@"name",@"address"]];
    for(NSDictionary * dic in array){
        NSLog(@"%@",dic);
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
