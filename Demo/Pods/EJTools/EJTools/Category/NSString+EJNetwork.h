//
//  NSString+EJNetwork.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN


@interface NSString (EJNetwork)

+ (NSString *)IP;

#pragma mark - split url

/**
 整合 API 访问路径

 @param server 服务器路径
 @param action 方法名
 @param param 参数
 @param isSign 是否签名
 @return 完整访问路径
 */
+ (NSString *)ej_getURLWithServer:(NSString *)server Action:(NSString *)action Parameters:(NSDictionary *)param isSign:(BOOL)isSign;

/**
 file api

 @param action <#action description#>
 @param param <#param description#>
 @return <#return value description#>
 */
//+ (NSString *)ej_getFileUrlWithAction:(NSString *)action Parameters:(NSDictionary *)param;

@end

//NS_ASSUME_NONNULL_END
