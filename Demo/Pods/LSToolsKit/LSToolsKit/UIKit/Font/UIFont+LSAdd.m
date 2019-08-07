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

@end
