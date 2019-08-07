//
//  UIView+LSAdd.m
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import "UIView+LSAdd.h"
#import <objc/runtime.h>

@implementation UIView (LSAdd)

static void *kLSCornerRadius = &kLSCornerRadius;

#pragma mark - 设置圆角
@dynamic ls_cornerRadius;
- (CGFloat)ls_cornerRadius {
    return [objc_getAssociatedObject(self, kLSCornerRadius) floatValue];
}

- (void)setLs_cornerRadius:(CGFloat)ls_cornerRadius {
    objc_setAssociatedObject(self, kLSCornerRadius, @(ls_cornerRadius), OBJC_ASSOCIATION_ASSIGN);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:ls_cornerRadius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
