//
//  NSArray+LSAdd.h
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (LSAdd)

/**
 获取数组中的指定元素，系统方法 数组越界会崩溃

 @param index index
 @return 指定元素 或 nil
 */
- (id)objectAtIndexByCheck:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
