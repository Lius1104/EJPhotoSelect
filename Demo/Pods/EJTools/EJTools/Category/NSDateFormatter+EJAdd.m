//
//  NSDateFormatter+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "NSDateFormatter+EJAdd.h"

@implementation NSDateFormatter (EJAdd)

+ (instancetype)dateFormatter {
    return [[self alloc] init];
}

+ (instancetype)dateFormatterWithFormat:(NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (instancetype)defaultDateFormatter {
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

@end
