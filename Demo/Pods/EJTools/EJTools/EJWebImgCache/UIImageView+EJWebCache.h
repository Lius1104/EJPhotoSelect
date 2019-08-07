//
//  UIImageView+EJWebCache.h
//  IOSParents
//
//  Created by Lius on 2017/8/9.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EJImageCompletionBlock)(UIImage * image, NSError * error, NSURL * imageURL);

@interface UIImageView (EJWebCache)

/**
 动态单张图片显示大小

 @param urlStr 网络图片链接
 @param maxW 最大允许的宽度
 @param ratio 宽高比
 @return 最终在屏幕上显示的imageview的size
 */
+ (CGSize)singleImageSizeWithUrlStr:(NSString *)urlStr withMaxWidth:(CGFloat)maxW ratio:(CGFloat)ratio;

+ (CGSize)originalWebImageSizeWithURLStr:(NSString *)urlStr;

/**
 通过网络链接加载网络图片

 @param strURL 网络链接字符串
 */
- (void)ej_setImageWithStringURL:(NSString *)strURL appendWidth:(BOOL)append;

- (void)ej_setImageWithStringURL:(NSString *)strURL appendWidth:(BOOL)append completed:(EJImageCompletionBlock)completedBlock;

/**
 通过网络链接加载网络图片,并且设置占位图

 @param strURL 网络链接字符串
 @param placeholderImage 占位图
 */
- (void)ej_setImageWithStringURL:(NSString *)strURL placeholperImage:(UIImage *)placeholderImage appendWidth:(BOOL)append;

- (void)ej_setImageWithStringURL:(NSString *)strURL placeholperImage:(UIImage *)placeholderImage appendWidth:(BOOL)append completed:(EJImageCompletionBlock)completedBlock;

@end
