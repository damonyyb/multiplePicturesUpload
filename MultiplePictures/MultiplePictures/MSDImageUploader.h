//
//  MSDUploader.h
//  HeraldleasingWorkAssistant
//
//  Created by bobo on 15/8/11.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(int, MSDImageUploaderType)
{
    MSDICONImageUploaderType =1,//头像
    MSDNormalImageUploaderType//普通图像
};

@interface MSDImageUploader : NSObject
/**
 *  单张图片上传
 *
 *  @param imageData 图片数据流
 *  @param num       图片是第几张
 *  @param type      图像类型
 *  @param block     URl，错误，第几张
 *
 *  @return NSURLSessionDataTask
 */
+(NSURLSessionDataTask *)post:(NSData*)imageData andOrderNum:(NSInteger )num type:(MSDImageUploaderType)type complete:(void (^)(NSString* urlString,NSError *error,NSInteger num))block;
/**
 *  AFN支持的多图上传（要求服务器可以下载多张图片才能使用，应该返回多个url，或者拼接后的url）
 *
 *  @param array 图片数据流数组
 *  @param type  类型
 *  @param block 返回url。错误
 *
 *  @return NSURLSessionDataTask
 */
+(NSURLSessionDataTask *)postImgsFromAFN:(NSArray<NSData *> *)array type:(MSDImageUploaderType)type complete:(void (^)(NSString* urlString,NSError *error))block;
/**
 *  开线程上传，会重新上传失败照片两次，三次都失败就返回上传失败的结果。
 *
 *  @param array 图片数据流数组
 *  @param type  图片类型
 *  @param block 返回（图片url数组，是否失败，失败信息）;
 */
+(void)postImgsThreesTimesFromGCD:(NSArray *)array type:(MSDImageUploaderType)type complete:(void (^)(NSArray * urlStringArr,BOOL failure,NSString *failureInfo))block;
@end
