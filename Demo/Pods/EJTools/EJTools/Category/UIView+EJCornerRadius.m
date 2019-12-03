//
//  UIView+EJCornerRadius.m
//  EJiangOSbeta
//
//  Created by 刘爽 on 2019/10/12.
//  Copyright © 2019 Joyssom. All rights reserved.
//

#import "UIView+EJCornerRadius.h"


@implementation UIView (EJCornerRadius)

- (void)ej_cornerRadius:(CGFloat)cornerRadius rectCorner:(UIRectCorner)rectCorner {
    if (@available(iOS 11.0, *)) {
        self.layer.cornerRadius = cornerRadius;
        self.layer.maskedCorners = (CACornerMask)rectCorner;
    } else {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
}

@end
