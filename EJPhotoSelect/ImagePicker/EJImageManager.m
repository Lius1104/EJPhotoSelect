//
//  EJImageManager.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImageManager.h"

@implementation EJImageManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static EJImageManager * manager;
    dispatch_once(&onceToken, ^{
        manager = [[EJImageManager alloc] init];
    });
    return manager;
}

- (BOOL)authorizationStatusAuthorized {
    NSInteger status = [PHPhotoLibrary authorizationStatus];
    if (status == 0) {
        /**
         * 当某些情况下AuthorizationStatus == AuthorizationStatusNotDetermined时，无法弹出系统首次使用的授权alertView，系统应用设置里亦没有相册的设置，此时将无法使用，故作以下操作，弹出系统首次使用的授权alertView
         */
        [self requestAuthorizationWithCompletion:nil];
    }
    
    return status == 3;
}

- (void)requestAuthorizationWithCompletion:(void (^)(void))completion {
    void (^callCompletionBlock)(void) = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callCompletionBlock();
        }];
    });
}

#pragma mark - gettter or setter
- (PHCachingImageManager *)cachingImageManager {
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

- (PHImageRequestOptions *)imageOptions {
    if (!_imageOptions) {
        _imageOptions = [[PHImageRequestOptions alloc] init];
        //        _options.synchronous = YES;//为了效果，我这里选择了同步 因为只获取一张照片，不会对界面产生很大的影响
        _imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        _imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    }
    return _imageOptions;
}

@end
