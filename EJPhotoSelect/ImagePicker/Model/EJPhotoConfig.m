//
//  EJPhotoConfig.m
//  AFNetworking
//
//  Created by 刘爽 on 2019/8/9.
//

#import "EJPhotoConfig.h"

@implementation EJPhotoConfig

+ (instancetype)sharedPhotoConfig {
    static EJPhotoConfig * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[EJPhotoConfig alloc] init];
    });
    return config;
}

@end
