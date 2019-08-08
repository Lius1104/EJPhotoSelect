//
//  UIDevice+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/8/6.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (EJAdd)

/**
 系统空闲空间大小
 
 @return size
 */
+ (unsigned long long)systemFreeSize;

/**
 系统全部空间大小
 
 @return size
 */
+ (unsigned long long)systemTotalSize;

/**
 剩余空间是否充足
 
 @param perentage 剩余空间百分比 [0~1]
 @return BOOL
 */
+ (BOOL)isEnoughFreeSizePer:(float)perentage;

@end

NS_ASSUME_NONNULL_END
