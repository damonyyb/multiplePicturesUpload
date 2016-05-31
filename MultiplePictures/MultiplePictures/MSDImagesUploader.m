//
//  MSDUploader.m
//  HeraldleasingWorkAssistant
//
//  Created by bobo on 15/8/11.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "MSDImagesUploader.h"
#import "AFNetworking.h"
#import "MD5.h"
#import "AFFileAPIClient.h"
static AFHTTPSessionManager* _afHTTPSessionManager;

static NSString * const MD5_KEY = @"abcdefg";


@implementation MSDImagesUploader
//////bobo
+(NSURLSessionDataTask *)post:(NSData*)imageData andOrderNum:(NSInteger )num type:(MSDImageUploaderType)type complete:(void (^)(NSString* urlString,NSError *error,NSInteger num))block
{
    NSString* userString = @"sh00085";
    NSString* md5Sign = [[NSString stringWithFormat:@"%@%@", userString, MD5_KEY]MD5];
    NSString* picTypeString = @"t_pic";
    if (type == MSDICONImageUploaderType) {
        picTypeString = @"t_photo";
    }
    NSDictionary *parameters =@{@"fid":picTypeString,@"uid":@"sh00085",@"sign":md5Sign};
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    return  [[AFFileAPIClient sharedClient] POST:@"fileService/upload.action"
                            parameters:parameters
        constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
            
            [formData appendPartWithFileData:imageData name:@"f" fileName:@"xxxx.jpeg" mimeType:@"application/octet-stream"];
        }
         success:^(NSURLSessionDataTask *task, id JSON){
             
             NSString* retCodeNum =  [JSON valueForKey:@"retCode"];
             int retCode =  [retCodeNum intValue];
             if(0 == retCode)
             {
                 NSString* urlString = [JSON valueForKey:@"url"];
                 if (block) {
                      block(urlString,nil,num);
                 }
             }
             else{
                 NSDictionary* NSErrorDic= @{@"retCode":@(retCode), @"message":@""};
                 if (block) {
                     block(nil, [[NSError alloc]initWithDomain:@"" code:0 userInfo:NSErrorDic],num);
                 }

             }
            //end默认处理
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
              block(nil,error,num);
         }];
}

+(NSURLSessionDataTask *)postImgsFromAFN:(NSArray<NSData *> *)array type:(MSDImageUploaderType)type complete:(void (^)(NSString* urlString,NSError *error))block{
    NSString* userString = @"sh00085";
    NSString* md5Sign = [[NSString stringWithFormat:@"%@%@", userString, MD5_KEY]MD5];
    NSString* picTypeString = @"t_pic";
    if (type == MSDICONImageUploaderType) {
        picTypeString = @"t_photo";
    }
    NSDictionary *parameters =@{@"fid":picTypeString,@"uid":@"sh00085",@"sign":md5Sign};
    
    return  [[AFFileAPIClient sharedClient] POST:@"fileService/upload.action"
                                      parameters:parameters
                       constructingBodyWithBlock:^(id <AFMultipartFormData> formData){
                           
                           for(NSInteger i = 0; i < array.count; i++) {
                           
                               NSData * imageData = [array objectAtIndex: i];
                               //AFN拼接数据流的固定格式，需要和服务器商量保持一致
                               [formData appendPartWithFileData:imageData name:@"f" fileName:@"xxxx.jpeg" mimeType:@"application/octet-stream"];
                           }
                       } success:^(NSURLSessionDataTask *task, id JSON){
                                             
                                             NSString* retCodeNum =  [JSON valueForKey:@"retCode"];
                                             int retCode =  [retCodeNum intValue];
                                             if(0 == retCode)
                                             {
                                                 NSString* urlString = [JSON valueForKey:@"url"];
                                                 if (block) {
                                                     block(urlString,nil);
                                                 }
                                             }
                                             else{
                                                 NSDictionary* NSErrorDic= @{@"retCode":@(retCode), @"message":@""};
                                                 if (block) {
                                                     block(nil, [[NSError alloc]initWithDomain:@"" code:0 userInfo:NSErrorDic]);
                                                 }
                                                 
                                             }
                                             //end默认处理
                                         }
                                         failure:^(NSURLSessionDataTask *task, NSError *error){
                                             block(nil,error);
                                         }];
}

+(void)postFailureImgsFromGCD:(NSArray *)array type:(MSDImageUploaderType)type complete:(void (^)(NSArray * urlStringArr,BOOL failure))block{
    
    NSMutableArray *urlStrArr =[NSMutableArray arrayWithArray:array];
    
    //创建组队列，保证异步线程完成后发end通知
    dispatch_group_t serviceGroup = dispatch_group_create();
    BOOL __block hasFailure;
    
    for (NSInteger i=0;i<array.count; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[NSData class]]) {
        //控制进dispatch_group_enter
        dispatch_group_enter(serviceGroup);
        
        [MSDImagesUploader post:array[i]  andOrderNum:i type:MSDNormalImageUploaderType  complete:^(NSString *urlString, NSError *error,NSInteger num) {
            if (!error) {
                NSLog(@"第%ld个成功==%@",(long)num,urlString);
                
                [urlStrArr replaceObjectAtIndex:i withObject:urlString];
            }else{
                NSLog(@"第%ld个失败==%@",(long)num,error);
                //失败
                  hasFailure = YES;
                
            }
            //控制出dispatch_group_leave
            dispatch_group_leave(serviceGroup);
            
        }];
            
       }
    }
    
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        //接受到组队列结束，返回结果
        NSLog(@"end");
        if (block ) {
            
            block([urlStrArr copy],hasFailure);
        }
    });
    
}
+(void)postImgsThreesTimesFromGCD:(NSArray *)array type:(MSDImageUploaderType)type complete:(void (^)(NSArray * urlStringArr,BOOL failure,NSString *failureInfo))block{
    [MSDImagesUploader postFailureImgsFromGCD:array type:MSDNormalImageUploaderType complete:^(NSArray *urlStringArr, BOOL failure) {
        if (!failure) {
            NSLog(@"success：第一次就全部上传成功");
            if (block ) {
                block([urlStringArr copy],NO,nil);
            }
        }else{
            
            [MSDImagesUploader postFailureImgsFromGCD:urlStringArr type:MSDNormalImageUploaderType complete:^(NSArray *urlStringSecondArr, BOOL failure) {
                
                if (!failure) {
                    NSLog(@"success：第二次全部上传成功");
                    if (block ) {
                        block([urlStringArr copy],NO,nil);
                    }
                }else{
                    [MSDImagesUploader postFailureImgsFromGCD:urlStringArr type:MSDNormalImageUploaderType complete:^(NSArray *urlStringThirdArr, BOOL failure) {
                        NSString *str = @"";
                        if (!failure) {
                            NSLog(@"success：第三次才上传成功");
                            if (block ) {
                                block([urlStringArr copy],NO,nil);
                            }
                        }else{
                            
                            for (NSInteger i=0; i<urlStringThirdArr.count; i++) {
                                if ([[urlStringThirdArr objectAtIndex:i] isKindOfClass:[NSData class]]) {
                                    [str stringByAppendingString:[NSString stringWithFormat:@"第%ld张照片",i+1]];
                                    continue;
                                }
                            }
                            [str stringByAppendingString:@"上传失败，请重新上传"];
                            
                            NSLog(@"%@",str);
                            if (block ) {
                                block([urlStringArr copy],YES,str);
                            }
                        }
      
                        
                    }];
                }
            }];
        }
        
    }];
    
    
}
@end
