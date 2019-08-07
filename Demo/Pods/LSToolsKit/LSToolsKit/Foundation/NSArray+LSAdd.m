//
//  NSArray+LSAdd.m
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#import "NSArray+LSAdd.h"

@implementation NSArray (LSAdd)

- (id)objectAtIndexByCheck:(NSUInteger)index {
    if(index < self.count)
        return [self objectAtIndex:index];
    else
        return nil;
}

@end
