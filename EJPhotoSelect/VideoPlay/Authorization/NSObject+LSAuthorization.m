//
//  NSObject+LSAuthorization.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/17.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "NSObject+LSAuthorization.h"

@implementation NSObject (LSAuthorization)

+ (void)judgeAppPhotoLibraryUsageAuth:(PhotoLibraryUsageAuthBlock)authBlock {
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    switch (oldStatus) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // 允许访问
                    authBlock(PHAuthorizationStatusAuthorized);
                } else {
                    // 拒绝访问
                    authBlock(PHAuthorizationStatusDenied);
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted: {
            authBlock(PHAuthorizationStatusRestricted);
        }
            break;
        case PHAuthorizationStatusDenied: {
            authBlock(PHAuthorizationStatusDenied);
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            authBlock(PHAuthorizationStatusAuthorized);
        }
            break;
    }
}

@end
