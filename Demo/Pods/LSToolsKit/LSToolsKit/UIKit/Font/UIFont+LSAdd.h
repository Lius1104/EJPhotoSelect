//
//  UIFont+LSAdd.h
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const PingFangSCMedium = @"PingFangSC-Medium";
static NSString *const PingFangSCBold = @"PingFangSC-Semibold";
static NSString *const PingFangSCRegular = @"PingFangSC-Regular";
static NSString *const PingFangSCLight = @"PingFangSC-Light";
static NSString *const PingFangeSCUltralight = @"PingFangSC-Ultralight";
static NSString *const PingFangSCThin = @"PingFangSC-Thin";

/**
 *  适配不同设备尺寸的字体类
 *  主要是UIFont方法中常用的五个Font创建方法
 */
@interface UIFont (LSAdd)

+ (UIFont *)ls_systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)ls_boldSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)ls_italicSystemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)ls_fontWithName:(NSString *)fontName size:(CGFloat)fontSize;
- (UIFont *)ls_fontWithSize:(CGFloat)fontSize;

+ (UIFont *)ls_pingFang:(NSString *)pingFangName WithSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
