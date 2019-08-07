//
//  UIButton+LSAdd.m
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import "UIButton+LSAdd.h"
#import <objc/runtime.h>

@interface UIButton ()
/**
 *  bool 设置是否执行触及事件方法
 */
//@property (nonatomic, assign) BOOL isExcuteEvent;

@end

static void *kLSCornerRadius = &kLSCornerRadius;
//static void *kLSTimeInterVal = &kLSTimeInterVal;

//static void *kLSIsExcuteEvent = &kLSIsExcuteEvent;

@implementation UIButton (LSAdd)

//static const CGFloat defaultInterval = 0.7f;

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

//#pragma mark - 防暴力点击
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        SEL oldSel = @selector(sendAction:to:forEvent:);
//        SEL newSel = @selector(newSendAction:to:forEvent:);
//        // 获取到上面新建的oldsel方法
//        Method oldMethod = class_getInstanceMethod(self, oldSel);
//        // 获取到上面新建的newsel方法
//        Method newMethod = class_getInstanceMethod(self, newSel);
//        // IMP 指方法实现的指针,每个方法都有一个对应的IMP,调用方法的IMP指针避免方法调用出现死循环问题
//        BOOL isAdd = class_addMethod(self, oldSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
//        if (isAdd) {
//            // 将newSel替换成oldMethod
//            class_replaceMethod(self, newSel, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
//        } else {
//            // 给两个方法互换实现
//            method_exchangeImplementations(oldMethod, newMethod);
//        }
//    });
//}
//
//- (void)newSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
////    if (self.isExcuteEvent == NO) {
////        self.ls_timeInterVal = (self.ls_timeInterVal == 0 ? defaultInterval : self.ls_timeInterVal);
////    }
////    if (self.isExcuteEvent) return;
////    if (self.ls_timeInterVal > 0) {
////        self.isExcuteEvent = YES;
////        [self performSelector:@selector(setIsExcuteEvent:) withObject:@(NO) afterDelay:self.ls_timeInterVal];
////    }
////    [self newSendAction:action to:target forEvent:event];
//    
//    
//    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
//        if (self.isExcuteEvent == 0) {
//            self.ls_timeInterVal = self.ls_timeInterVal == 0 ? defaultInterval : self.ls_timeInterVal;
//        }
//        if (self.isExcuteEvent) return;
//        if (self.ls_timeInterVal > 0) {
//            self.isExcuteEvent = YES;
//            [self performSelector:@selector(setIsExcuteEvent:) withObject:nil afterDelay:self.ls_timeInterVal];
//        }
//    }
//    [self newSendAction:action to:target forEvent:event];
//}
//
//@dynamic ls_timeInterVal;
//- (NSTimeInterval)ls_timeInterVal {
//    // 动态获取关联对象
//    return [objc_getAssociatedObject(self, kLSTimeInterVal) doubleValue];
//}
//
//- (void)setLs_timeInterVal:(NSTimeInterval)ls_timeInterVal {
//    // 动态设置关联对象
//    // tip : double类型 时，应为 OBJC_ASSOCIATION_RETAIN_NONATOMIC
//    objc_setAssociatedObject(self, kLSTimeInterVal, @(ls_timeInterVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (void)setIsExcuteEvent:(BOOL)isExcuteEvent {
//    // 动态设置关联对象
//    objc_setAssociatedObject(self, kLSIsExcuteEvent, @(isExcuteEvent), OBJC_ASSOCIATION_ASSIGN);
//}
//
//- (BOOL)isExcuteEvent {
//    // 动态获取关联对象
//    return [objc_getAssociatedObject(self, kLSIsExcuteEvent) boolValue];
//}

@end
