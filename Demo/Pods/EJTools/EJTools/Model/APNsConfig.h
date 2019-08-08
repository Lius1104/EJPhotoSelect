//
//  APNsConfig.h
//  JoyssomEdu
//
//  Created by Shuang Lau on 2018/11/1.
//  Copyright © 2018 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APNsConfig : NSObject

+ (BOOL)isMessageWithType:(NSUInteger)msgType RemotePush:(NSDictionary *)userInfo;

//+ (NSUInteger)getAPNMessageObjectType:(NSDictionary *)userInfo;

+ (NSString *)getAPNMessageObjectId:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
