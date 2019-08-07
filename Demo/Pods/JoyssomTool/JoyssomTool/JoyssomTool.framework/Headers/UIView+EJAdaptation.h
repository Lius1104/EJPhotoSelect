//
//  UIView+EJAdaptation.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface UIView (EJAdaptation)

#pragma mark - 1/3G/3GS/4/4s (320 * 480_3.5-inch)

#pragma mark - 5/5s/5c (320 * 568_4-inch)
+ (CGFloat)ej_widthAt5ByWidth:(CGFloat)width;

+ (CGFloat)ej_widthAt5ByWidth:(CGFloat)width height:(CGFloat)height;

+ (CGFloat)ej_heightAt5ByHeight:(CGFloat)height;

+ (CGFloat)ej_heightAt5RatioByHeight:(CGFloat)height with:(CGFloat)width;

- (CGFloat)ej_cornerRadiusAt5ByWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius;
#pragma mark - 6/6s/7 (375 * 667_4.7-inch)
+ (CGFloat)ej_widthAt6sByWidth:(CGFloat)width;

+ (CGFloat)ej_heightAt6sByHeight:(CGFloat)height;

+ (CGFloat)ej_heightAt6sRatioByHeight:(CGFloat)height with:(CGFloat)width;

- (CGFloat)ej_cornerRadiusAt6sByWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius;

#pragma mark - 6p/6sp/7p (414 * 736_5.5inch)

@end

//NS_ASSUME_NONNULL_END
