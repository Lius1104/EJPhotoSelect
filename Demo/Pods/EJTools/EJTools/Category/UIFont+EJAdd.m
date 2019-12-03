//
//  UIFont+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "UIFont+EJAdd.h"

@implementation UIFont (EJAdd)

+ (UIFont *)ej_pingFangSCRegularOfSize:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
    if (font == nil) {
        font = [UIFont fontWithName:@"PingFang-SC-Regular" size:fontSize];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)ej_pingFangSCMediumOfSize:(CGFloat)fontSize {
    // PingFang-SC-Medium
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
    if (font == nil) {
        font = [UIFont fontWithName:@"PingFang-SC-Medium" size:fontSize];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)ej_pingFangSCBoldOfSize:(CGFloat)fontSize {
    // PingFang-SC-Bold
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Bold" size:fontSize];
    if (font == nil) {
        font = [UIFont fontWithName:@"PingFang-SC-Bold" size:fontSize];
    }
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

@end
