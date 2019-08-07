//
//  EJWebImgCache.h
//  IOSParents
//
//  Created by Lius on 2017/8/10.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+EJWebCache.h"

typedef NS_ENUM(NSUInteger, EJWebImgUseMode) {
    EJWebImgUseModeHeader         = 0,          //头像
    EJWebImgUseModeChat,                        //交流群组
    EJWebImgUseModeBanner,                      // 轮播图
    
    EJWebImgUseModeSmall,                       // 方图 60 x 60 ,2x
    EJWebImgUseModeNormal,                      // 方图 180 x 180 , 2x
    EJWebImgUseModeLarge,                       // 方图 540 x 540 , 2x
    
    EJWebImgUseMode3x4,                         // 宽高比 3 ：4，375 出图
    EJWebImgUseMode4x3,                         // 宽高比 4 ；3，375 出图
    
    EJWebImgUseMode16x9,                        // 宽高比 16 ：9，375 出图
    EJWebImgUseMode9x16,                        // 宽高比 9 ：16，375 出图
    
    EJWebImgUseModeOther                        // 其他类型, placeHolder 缺省
};



/**
 * 定义不同 类型的默认占位图 可定义一下：
 * EJWebImgUseModeHeader => kEJWebHeaderBlank
 * EJWebImgUseModeChat => kEJWebChatBlank
 * EJWebImgUseModeBanner => kEJWebBannerBlank
 * EJWebImgUseModeSmall => kEJWebSmallBlank
 * EJWebImgUseModeNormal => kEJWebNormalBlank
 * EJWebImgUseModeLarge => kEJWebLargeBlank
 * EJWebImgUseMode3x4 => kEJWeb3x4Blank
 * EJWebImgUseMode4x3 => kEJWeb4x3Blank
 * EJWebImgUseMode16x9 => kEJWeb16x9Blank
 * EJWebImgUseMode9x16 => kEJWeb9x16Blank
 * EJWebImgUseModeOther => kEJWebOtherBlank
 */
@interface EJWebImgCache : NSObject


/**
 加载网络图片到UIImageView

 @param imgView 加载的网络图片的载体
 @param placeholder 占位图,可为空; 为空时默认是UI设计展位图
 @param strURL 网络加载的链接
 @param useMode 图片载体使用位置
 */
+ (void)ej_setImageWithCarrier:(UIImageView *)imgView placeholder:(UIImage *)placeholder strURL:(NSString *)strURL useMode:(EJWebImgUseMode)useMode;

+ (void)ej_setImageWithCarrier:(UIImageView *)imgView placeholder:(UIImage *)placeholder strURL:(NSString *)strURL useMode:(EJWebImgUseMode)useMode completed:(EJImageCompletionBlock)webImgCompletedBlock;

@end
