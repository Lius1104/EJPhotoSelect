//
//  NSMutableArray+LSAdd.m
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import "NSMutableArray+LSAdd.h"

@implementation NSMutableArray (LSAdd)

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    if (toIndex != fromIndex && fromIndex < [self count] && toIndex <= [self count]) {
        id obj = [self objectAtIndex:fromIndex];
        [self removeObjectAtIndex:fromIndex];
        if (toIndex >= [self count] + 1) {
            [self addObject:obj];
        } else {
            if (fromIndex < toIndex) {
                [self insertObject:obj atIndex:toIndex - 1];
            } else {
                [self insertObject:obj atIndex:toIndex];
            }
        }
    }
}

@end
