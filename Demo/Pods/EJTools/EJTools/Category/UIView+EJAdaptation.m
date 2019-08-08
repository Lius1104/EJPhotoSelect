//
//  UIView+EJAdaptation.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "UIView+EJAdaptation.h"

@implementation UIView (EJAdaptation)

#define kEJScreenWidth ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define kEJScreenHeight ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

#pragma mark - 1/3G/3GS/4/4s (320 * 480_3.5-inch)

#pragma mark - 5/5s/5c (320 * 568_4-inch)
+ (CGFloat)ej_widthAt5ByWidth:(CGFloat)width {
    return ceil(kEJScreenWidth * width / (320 * 2));
}

+ (CGFloat)ej_widthAt5ByWidth:(CGFloat)width height:(CGFloat)height {
    return ceil([self ej_heightAt5ByHeight:height] * width / height);
}

+ (CGFloat)ej_heightAt5ByHeight:(CGFloat)height {
    return ceil(kEJScreenHeight * height / (568 * 2));
}

+ (CGFloat)ej_heightAt5RatioByHeight:(CGFloat)height with:(CGFloat)width {
    return ceil([self ej_widthAt5ByWidth:width] * height / width);
}

- (CGFloat)ej_cornerRadiusAt5ByWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius {
    return ceil([UIView ej_widthAt5ByWidth:width] * cornerRadius / width);
}
#pragma mark - 6/6s/7 (375 * 667_4.7-inch)
+ (CGFloat)ej_widthAt6sByWidth:(CGFloat)width {
    return ceil(kEJScreenWidth * width / (375 * 2));
}

+ (CGFloat)ej_heightAt6sByHeight:(CGFloat)height {
    return ceil(kEJScreenHeight * height / (667 * 2));
}

+ (CGFloat)ej_heightAt6sRatioByHeight:(CGFloat)height with:(CGFloat)width {
    return ceil([self ej_widthAt6sByWidth:width] * height / width);
}

- (CGFloat)ej_cornerRadiusAt6sByWidth:(CGFloat)width cornerRadius:(CGFloat)cornerRadius {
    return ceil([UIView ej_widthAt6sByWidth:width] * cornerRadius / width);
}

#pragma mark - 6p/6sp/7p (414 * 736_5.5inch)

@end
