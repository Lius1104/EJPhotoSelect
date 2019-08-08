//
//  APNsConfig.m
//  JoyssomEdu
//
//  Created by Shuang Lau on 2018/11/1.
//  Copyright © 2018 Shuang Lau. All rights reserved.
//

#import "APNsConfig.h"

@implementation APNsConfig

+ (BOOL)isMessageWithType:(NSUInteger)msgType RemotePush:(NSDictionary *)userInfo {
    if (userInfo == nil) {
        return NO;
    }
    BOOL isHave = NO;
    for (NSString *str in userInfo.allKeys) {
        if ([str isEqualToString:@"payload"]) {
            isHave = YES;
            break;
        }
    }
    if (isHave == NO) return NO;
    id payload = userInfo[@"payload"];
    if ([payload isKindOfClass:[NSString class]]) {
        NSString *content = (NSString *)payload;
        if ([content length] == 0) return NO;
        NSArray *array = [content componentsSeparatedByString:@"|"];
        if ([array count] == 0) return NO;
        NSInteger type = [[array firstObject] integerValue];
        if (type == msgType) {
            return YES;
        } else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

+ (NSString *)getAPNMessageObjectId:(NSDictionary *)userInfo {
    if (userInfo == nil) {
        return nil;
    }
    BOOL isHave = NO;
    for (NSString *str in userInfo.allKeys) {
        if ([str isEqualToString:@"payload"]) {
            isHave = YES;
            break;
        }
    }
    if (isHave == NO) return nil;
    id payload = userInfo[@"payload"];
    if ([payload isKindOfClass:[NSString class]]) {
        NSString *content = (NSString *)payload;
        if ([content length] == 0) return nil;
        NSArray *array = [content componentsSeparatedByString:@"|"];
        if ([array count] == 0 || [array count] == 1) return nil;
        NSString * objectId = [array lastObject];
        return objectId;
    }
    else {
        return nil;
    }
}

@end
