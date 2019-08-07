//
//  NSString+EJShot.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "NSString+EJShot.h"

@implementation NSString (EJShot)

+ (NSString *)ej_shotDicPath {
    NSString *userFilePath = [NSString stringWithFormat:@"%@/Shot", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject]];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:userFilePath];
    if (isExists) {
        return userFilePath;
    } else {
        BOOL bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:userFilePath
                                                    withIntermediateDirectories:YES
                                                                     attributes:nil
                                                                          error:nil];
        if(bCreateDir) {
            return userFilePath;
        }
    }
    return nil;
}

+ (NSString *)shortedSecond:(NSUInteger)second {
    if (second < 60) {
        return [NSString stringWithFormat:@"00:%02d", (int)second];
    } else if (second < 60 * 60) {
        return [NSString stringWithFormat:@"%02d:%02d", (int)second / 60, (int)second % 60];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)second / 3600, (int)second % 3600 / 60, (int)second % 3600 % 60];
    }
}

@end
