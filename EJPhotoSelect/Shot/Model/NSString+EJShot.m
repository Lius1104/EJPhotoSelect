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

+ (NSString *)shortedSecond:(CGFloat)second {
    CGFloat result = ceil(second);
    if (result < 60) {
        return [NSString stringWithFormat:@"00:%02d", (int)result];
    } else if (result < 60 * 60) {
        return [NSString stringWithFormat:@"%02d:%02d", (int)result / 60, (int)result % 60];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", (int)result / 3600, (int)result % 3600 / 60, (int)result % 3600 % 60];
    }
}

@end
