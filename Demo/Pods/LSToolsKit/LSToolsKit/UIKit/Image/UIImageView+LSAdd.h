//
//  UIImageView+LSAdd.h
//  LSToolsKitDemo
//
//  Created by LiuShuang on 2019/6/10.
//  Copyright © 2019 刘爽. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (LSAdd)

/**
 获取动态列表中单张网络图片的尺寸

 @param urlStr image url
 @param maxW 最大宽度
 @param ratio 图片宽高比
 @return 单张图片的size
 */
+ (CGSize)ls_singleImageSizeWithUrlStr:(NSString * _Nullable)urlStr withMaxWidth:(CGFloat)maxW ratio:(CGFloat)ratio;

/**
 获取 网络图片的大小

 @param urlStr image url
 @return 单张网络图片的size
 */
+ (CGSize)ls_originalWebImageSizeWithURLStr:(NSString * _Nullable)urlStr;

@end

//NS_ASSUME_NONNULL_END
