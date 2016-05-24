//
//  AFFileAPIClien.m
//  VehicleBone
//
//  Created by bobo on 15/8/12.
//  Copyright (c) 2015年 mesada. All rights reserved.
//
// 针对支援服务器

#import "AFFileAPIClient.h"
//#define FileServPrefix				@""     //OK

@implementation AFFileAPIClient

+ (instancetype)sharedClient {
    static AFFileAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#warning  服务器写公司的文件服务器地址才能编译通过  //#define FileServPrefix				@""     //OK    取消注释
        
        _sharedClient = [[AFFileAPIClient alloc] initWithBaseURL:[NSURL URLWithString:FileServPrefix]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:3];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    
    
    return _sharedClient;
}
@end
