//
//  LSButton.h
//  LSKitDemo
//
//  Created by Lius on 2017/5/5.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKitEnums.h"
/**
 扩大指定方向的点击范围 的 button
 */
@interface LSButton : UIButton
/**
 expendX 是 期望的单边扩大的px，不是扩大范围后的总 width
 */
@property (nonatomic, assign) CGFloat expendX;

/**
 expendX 是 期望的单边扩大的px，不是扩大范围后的总 height
 */
@property (nonatomic, assign) CGFloat expendY;

/**
 when use it, you can decide one or more direction that you want expand. default is ExpandingDirectionNone.
 */
@property (nonatomic, assign) ExpandingDirectionType expendDirection;


@end
