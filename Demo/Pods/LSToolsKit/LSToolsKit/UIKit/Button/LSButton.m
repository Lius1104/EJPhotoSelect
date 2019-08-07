//
//  LSButton.m
//  LSKitDemo
//
//  Created by Lius on 2017/5/5.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import "LSButton.h"

@implementation LSButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.expendX = 0;//frame.size.width
        self.expendY = 0;//frame.size.height
        self.expendDirection = ExpandingDirectionNone;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //通过修改bounds 的x,y 值就可以只向X 轴或者Y轴的某一个方向扩展

    //当bounds 的X 为负,Y 为0,就只向X的正方向扩展点击区域,反之亦然

    //当bounds 的Y 为负,X 为0,就只向Y的正方向扩展点击区域,反之亦然

    //当bounds 的Y 为0,X 为0,widthDelta,heightDelta来控制扩大的点击区域 ,这个是同时向X 轴正负方向或者同时向Y轴的正负方向
    CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    //expendX,expendY 是希望的X 轴或者Y轴方向的点击区域的宽度或者高度
    CGFloat widthDelta = self.expendX;
    CGFloat heightDelta = self.expendY;
    if (self.expendDirection & ExpandingDirectionTop) {
        //向上扩展
        bounds.origin.y = -(heightDelta / 2.f);
    }
    if (self.expendDirection & ExpandingDirectionBottom) {
        //向下扩展
        if (bounds.origin.y < 0) {
            bounds.size.height += self.expendY;
        } else {
            bounds.origin.y = (heightDelta / 2.f);
        }
    }
    if (self.expendDirection & ExpandingDirectionLeft) {
        //向左扩展
        bounds.origin.x = - (widthDelta / 2.f);
    }
    if (self.expendDirection & ExpandingDirectionRight) {
        //向右扩展
        if (bounds.origin.x < 0) {
            bounds.size.width += self.expendX;
        } else {
            bounds.origin.x = (widthDelta / 2.f);
        }
    }

    bounds = CGRectInset(bounds, - 0.5 * widthDelta, - 0.5 * heightDelta);//注意这里是负数，扩大了之前的bounds的范围
    return CGRectContainsPoint(bounds, point);
}

@end
