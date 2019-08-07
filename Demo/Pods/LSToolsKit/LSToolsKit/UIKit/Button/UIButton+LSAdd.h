//
//  UIButton+LSAdd.h
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LSAdd)

/**
 设置按钮圆角
 */
@property (nonatomic, assign) CGFloat ls_cornerRadius;

/**
 *  设置点击时间间隔, 防止暴力点击
 */
//@property (nonatomic, assign) NSTimeInterval ls_timeInterVal;//default is 2.f.

@end

NS_ASSUME_NONNULL_END
