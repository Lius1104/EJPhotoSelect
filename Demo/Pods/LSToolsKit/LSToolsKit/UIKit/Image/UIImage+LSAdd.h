//
//  UIImage+LSAdd.h
//  LSKitDemo
//
//  Created by Lius on 2017/5/5.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/UIImageView+WebCache.h>

/**
 解决 UIImageJPEGRepresentation 针对部分图片返回 nil 的问题

 @param image 需要存储的image
 @param compressionQuality 压缩比例
 @return data
 */
NSData * __nullable LSImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality);

@interface UIImage (LSAdd)

//调整图片的方向
- (UIImage * _Nonnull)fixOrientation;
/**
 *  类方法：压缩图片到指定尺寸
 */
+ (UIImage * _Nonnull)imageCompress:(UIImage * _Nonnull)imge scaleToSize:(CGSize)size;
/**
 *  压缩图片到限定范围内
 */
+ (UIImage * _Nonnull)imageCompress:(UIImage * _Nonnull)image limitToSize:(CGSize)limitSize;

/**
 *  压缩图片到指定范围内（符合原尺寸比例并且只有宽或高在指定的边缘范围内即可）
 */
+ (UIImage * _Nonnull)imageCompress:(UIImage * _Nonnull)image edgeSize:(CGSize)edgeSize;
/**
 *  实例方法：压缩图片到指定尺寸
 */
- (UIImage *_Nonnull)imageByScalingToSize:(CGSize)targetSize;
/**
 *  实例方法：改变图片尺寸，（fenbianl）
 */
//- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height;
/**
 * 压缩到指定文件大小
 */
- (NSData * _Nonnull)imageCompressToLimitBitSize:(CGFloat)limitBitSize;
/**
 * 返回一个纯色的image, UIImage改颜色
 */
- (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color;

/**
 文字转图片

 @param string <#string description#>
 @param attributes <#attributes description#>
 @param size <#size description#>
 @param bgColor <#bgColor description#>
 @return <#return value description#>
 */
+ (UIImage * _Nonnull)imageFromString:(NSString * _Nonnull)string attributes:(NSDictionary * _Nullable)attributes size:(CGSize)size backgroundColor:(UIColor * _Nullable)bgColor;

/**
 * 获得视频针的截图
 */
+ (UIImage * _Nonnull)thumbnailImageForVideo:(NSURL * _Nonnull)videoURL atTime:(NSTimeInterval)time;

+ (UIImage * _Nonnull)getFirstThumbImage:(NSURL * _Nonnull)videoURL;

/*!
 * @brief 根据指定的Rect来截取图片，返回截取后的图片
 * @param rect 指定的Rect，如果大小超过图片大小，就会返回原图片
 * @return 返回截取后的图片
 */
- (UIImage * _Nonnull)subImageWithRect:(CGRect)rect;

/*!
 * @brief 把图片等比例缩放到指定的size
 * @param size 缩放后的图片的大小
 * @return 返回缩放后的图片
 */
- (UIImage * _Nonnull)scaleToSize:(CGSize)size;

/**
 从网络获取图片

 @param imageUrl 链接字符串
 @return 网络图片
 */
+ (UIImage * _Nonnull)imageWithUrlString:(NSString * _Nonnull)imageUrl;

/**
 群组头像拼接

 @param images 需要拼接的头像
 @return 拼接后的头像
 */
+ (UIImage * _Nonnull)combine:(NSArray<UIImage *> * _Nonnull)images;

@end
