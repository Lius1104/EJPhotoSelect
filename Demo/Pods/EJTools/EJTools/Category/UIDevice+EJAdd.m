//
//  UIDevice+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/8/6.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "UIDevice+EJAdd.h"

@implementation UIDevice (EJAdd)

+ (unsigned long long)systemTotalSize {
    unsigned long long total = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber * size = [dictionary objectForKey:NSFileSystemSize];
        total = [size unsignedLongLongValue];
    }
    return total;
}

+ (unsigned long long)systemFreeSize {
    unsigned long long free = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber * size = [dictionary objectForKey:NSFileSystemFreeSize];
        free = [size unsignedLongLongValue];
    }
    return free;
}

+ (BOOL)isEnoughFreeSizePer:(float)perentage {
    unsigned long long free = [self systemFreeSize];
    unsigned long long total = [self systemTotalSize];
    return free * 1.0 / total >= perentage;
}


@end
