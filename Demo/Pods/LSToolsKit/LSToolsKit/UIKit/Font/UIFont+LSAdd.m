//
//  UIFont+LSAdd.m
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import "UIFont+LSAdd.h"

@implementation UIFont (LSAdd)

#define UIScreenWidth 375  //自己UI设计原型图的手机尺寸宽度(6)

+ (CGFloat)adapterFontOfSize:(CGFloat)fontSize {
    CGFloat size = fontSize;
    size = round(fontSize * [UIScreen mainScreen].bounds.size.width/UIScreenWidth);
    return size;
}

+ (UIFont *)ls_systemFontOfSize:(CGFloat)fontSize {
    CGFloat size = [self adapterFontOfSize:fontSize];
    return [self systemFontOfSize:size];
}

+ (UIFont *)ls_boldSystemFontOfSize:(CGFloat)fontSize {
    CGFloat size = [self adapterFontOfSize:fontSize];
    return [self boldSystemFontOfSize:size];
}

+ (UIFont *)ls_italicSystemFontOfSize:(CGFloat)fontSize {
    CGFloat size = [self adapterFontOfSize:fontSize];
    return [self italicSystemFontOfSize:size];
}

+ (UIFont *)ls_fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    CGFloat size = [self adapterFontOfSize:fontSize];
    return [self fontWithName:fontName size:size];
}

- (UIFont *)ls_fontWithSize:(CGFloat)fontSize {
    CGFloat size = [UIFont adapterFontOfSize:fontSize];
    return [self fontWithSize:size];
}

+ (UIFont *)ls_pingFang:(NSString *)pingFangName WithSize:(CGFloat)size {
    UIFont * font = [UIFont fontWithName:pingFangName size:size];
    if (font == nil) {
        if (@available(iOS 8.2, *)) {
            if ([pingFangName isEqualToString:PingFangSCMedium]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
            } else if ([pingFangName isEqualToString:PingFangSCBold]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightBold];
            } else if ([pingFangName isEqualToString:PingFangSCRegular]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
            } else if ([pingFangName isEqualToString:PingFangSCThin]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightThin];
            } else if ([pingFangName isEqualToString:PingFangSCLight]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightLight];
            } else if ([pingFangName isEqualToString:PingFangeSCUltralight]) {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightUltraLight];
            } else {
                font = [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
            }
        } else {
            // Fallback on earlier versions
            if ([pingFangName isEqualToString:PingFangSCBold]) {
                font = [UIFont boldSystemFontOfSize:size];
            } else {
                font = [UIFont systemFontOfSize:size];
            }
        }
    }
    return font;
}

@end
