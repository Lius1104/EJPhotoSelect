//
//  NSString+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/21.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "NSString+EJAdd.h"

@implementation NSString (EJAdd)

- (NSString *)ej_noWhiteSpaceString {
    NSString *newString = self;
    //去除掉首尾的空白字符和换行字符
    newString = [newString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符使用
    newString = [newString stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    可以去掉空格，注意此时生成的strUrl是autorelease属性的，所以不必对strUrl进行release操作！
    return newString;
}

+ (NSString *)ej_getUUID {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}

+ (NSString *)ej_shortedNumberDesc:(NSUInteger)number {
    // should be localized
    if (number <= 999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999) return [NSString stringWithFormat:@"%d千", (int)(number / 1000)];
    return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
}

+ (NSString *)ej_shortedCount:(NSUInteger)count {
    if (count > 99) {
        return @"99+";
    } else {
        return [NSString stringWithFormat:@"%d", (int)count];
    }
}

+ (NSString *)ej_shortedSecond:(NSUInteger)second {
    if (second < 60) {
        return [NSString stringWithFormat:@"00:%02d", (int)second];
    } else if (second < 60 * 60) {
        return [NSString stringWithFormat:@"%02d:%02d", (int)second / 60, (int)second % 60];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)second / 3600, (int)second % 3600 / 60, (int)second % 3600 % 60];
    }
}

+ (NSString *)ej_getMMSSFromSeconds:(NSUInteger)seconds {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld", (long)seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long)(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long)seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@", str_hour, str_minute, str_second];
    
    return format_time;
    
}

@end
