//
//  ViewController.m
//  MultiplePictures
//
//  Created by yyb on 16/5/24.
//  Copyright © 2016年 yyb. All rights reserved.
//

#import "ViewController.h"
#import "MSDImagesUploader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self onePicUploader];
//    [self twoPicUploader];
    [self threePicUploader];
}
//测试一张图
- (void)onePicUploader{
     UIImage *image =[UIImage imageNamed:@"1"];
     NSData *imageData =UIImageJPEGRepresentation(image, 0.5);
    
    [MSDImagesUploader post:imageData  andOrderNum:0 type:MSDNormalImageUploaderType  complete:^(NSString *urlString, NSError *error,NSInteger num) {
        if (!error) {
            NSLog(@"第%ld个==%@",(long)num,urlString);
        }
        
    }];
    
}
//测试两张图使用AFN
- (void)twoPicUploader{
    UIImage *image =[UIImage imageNamed:@"1"];
    NSData *imageData =UIImageJPEGRepresentation(image, 0.5);
    UIImage *image2 = [UIImage imageNamed:@"2"];
     NSData *imageDate2 =UIImageJPEGRepresentation(image2, 0.5);
    
    [MSDImagesUploader postImgsFromAFN: @[imageDate2,imageData] type:MSDNormalImageUploaderType complete:^(NSString *urlString, NSError *error) {
        if (!error) {
            NSLog(@"%@",urlString);
        }
    }];
    
}
//测试54张图片多线程上传  
- (void)threePicUploader{
    UIImage *image =[UIImage imageNamed:@"1"];
    NSData *imageData =UIImageJPEGRepresentation(image, 0.5);
    UIImage *image2 = [UIImage imageNamed:@"2"];
    NSData *imageDate2 =UIImageJPEGRepresentation(image2, 0.5);
    UIImage *image3 = [UIImage imageNamed:@"3"];
    NSData *imageDate3 = UIImageJPEGRepresentation(image3, 0.5);

    NSArray *array = @[imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData,
                       imageData,imageDate2,imageDate3,imageDate3,imageDate2,imageData];
    
    [MSDImagesUploader postImgsThreesTimesFromGCD:array type:MSDNormalImageUploaderType complete:^(NSArray *urlStringArr, BOOL failure,NSString *failureStr) {
        if (!failure) {
            NSLog(@"%@",urlStringArr);
        }else{
            NSLog(@"%@",failureStr);
            
        }
    }];
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
