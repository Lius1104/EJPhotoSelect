//
//  NSDictionary+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (EJAdd)

+ (NSDictionary *)ej_dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)ej_dictionaryToJson:(NSDictionary *)dic;

@end

//NS_ASSUME_NONNULL_END
