//
//  NSString+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/21.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (EJAdd)

- (NSString *)ej_noWhiteSpaceString;

+ (NSString *)ej_getUUID;

+ (NSString *)ej_shortedNumberDesc:(NSUInteger)number;

+ (NSString *)ej_shortedCount:(NSUInteger)count;

+ (NSString *)ej_shortedSecond:(NSUInteger)second;

+ (NSString *)ej_getMMSSFromSeconds:(NSUInteger)seconds;

@end

NS_ASSUME_NONNULL_END
