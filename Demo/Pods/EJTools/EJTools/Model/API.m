//
//  API.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/20.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "API.h"

@implementation API

+ (instancetype)sharedApi {
    static API * model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[API alloc] init];
    });
    return model;
}

@end
