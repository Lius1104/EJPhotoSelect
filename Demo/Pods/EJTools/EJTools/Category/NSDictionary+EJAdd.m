//
//  NSDictionary+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "NSDictionary+EJAdd.h"

@implementation NSDictionary (EJAdd)

+ (NSDictionary *)ej_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

+ (NSString *)ej_dictionaryToJson:(NSDictionary *)dic {
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    //    NSJSONWritingPrettyPrinted  是有换位符的。
    //    如果NSJSONWritingPrettyPrinted 是nil 的话 返回的数据是没有 换位符的
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

@end
