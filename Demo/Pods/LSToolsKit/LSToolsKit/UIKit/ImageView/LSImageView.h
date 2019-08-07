//
//  LSImageView.h
//  LSKitDemo
//
//  Created by Lius on 2017/5/5.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKitEnums.h"

@interface LSImageView : UIImageView

/**
 expendX 是 期望的单边扩大的px，不是扩大范围后的总 width
 */
@property (nonatomic, assign) CGFloat expendX;

/**
 expendX 是 期望的单边扩大的px，不是扩大范围后的总 height
 */
@property (nonatomic, assign) CGFloat expendY;

/**
 按钮点击范围的扩大方向，目前只支持单个方向的扩大
 */
@property (nonatomic, assign) ExpandingDirectionType expendDirection;

@end
