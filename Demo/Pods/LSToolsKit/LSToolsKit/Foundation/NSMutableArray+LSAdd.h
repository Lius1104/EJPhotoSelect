//
//  NSMutableArray+LSAdd.h
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (LSAdd)

/**
 移动可变数组中的某一元素到数组中的指定位置
 
 @param fromIndex 需要移动的元素的当前位置
 @param toIndex 需要移动到的位置
 */
- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

NS_ASSUME_NONNULL_END
