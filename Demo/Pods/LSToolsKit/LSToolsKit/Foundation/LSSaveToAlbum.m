//
//  LSSaveToAlbum.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/17.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSSaveToAlbum.h"

@interface LSSaveToAlbum ()

@property (nonatomic, copy) NSString * albumName;

@end

@implementation LSSaveToAlbum

+ (LSSaveToAlbum *)mainSave {
    static dispatch_once_t onceToken;
    static LSSaveToAlbum * manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[LSSaveToAlbum alloc] init];
        // 默认相册名称是 app的
        NSDictionary * infoDict = [NSBundle mainBundle].infoDictionary;
        manager.albumName = [infoDict objectForKey:@"CFBundleDisplayName"];
    });
    return manager;
}

- (void)configCustomAlbumName:(NSString *)customName {
    if ([customName length] == 0) {
        NSLog(@"相册名称为空，将自动使用 app 名称");
        return;
    }
    self.albumName = customName;
}

#pragma mark - create new
- (void)saveImage:(UIImage *)image successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure {
    __block NSString * Identify = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if (@available(iOS 9.0, *)) {
            Identify = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } else {
            Identify = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;    
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            NSLog(@"保存到系统相册失败");
            failure(error);
            return;
        }
        block(Identify);
        // 添加索引到自定义相册
        [self saveToCustomAlbum:Identify];
    }];
}

- (void)saveImageWithUrl:(NSURL *)imgUrl successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure {
    __block NSString * Identify = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if (@available(iOS 9.0, *)) {
            Identify = [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:imgUrl].placeholderForCreatedAsset.localIdentifier;
        } else {
            Identify = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imgUrl].placeholderForCreatedAsset.localIdentifier;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            NSLog(@"保存到系统相册失败");
            failure(error);
            return;
        }
        block(Identify);
        [self saveToCustomAlbum:Identify];
    }];
}

- (void)saveVideoWithUrl:(NSURL *)videoUrl successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure {
    __block NSString * Identify = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        if (@available(iOS 9.0, *)) {
            Identify = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoUrl].placeholderForCreatedAsset.localIdentifier;
        } else {
            Identify = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl].placeholderForCreatedAsset.localIdentifier;
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success == NO) {
            NSLog(@"保存到系统相册失败");
            failure(error);
            return;
        }
        block(Identify);
        [self saveToCustomAlbum:Identify];
    }];
}

#pragma mark - private
- (PHAssetCollection *)customAlbum {
    PHFetchResult <PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * collection in result) {
        if ([collection.localizedTitle isEqualToString:self.albumName]) {
            return collection;
        }
    }
    NSError * error = nil;
    __block NSString * Identify = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest * request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:self.albumName];
        PHObjectPlaceholder * placeholder = request.placeholderForCreatedAssetCollection;
        Identify = placeholder.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    } else {
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[Identify] options:nil].lastObject;
    }
}

- (void)saveToCustomAlbum:(NSString *)identify {
    PHAssetCollection * collection = [self customAlbum];
    if (collection == nil) {
        NSLog(@"找不到本地的app相册");
        return;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identify] options:nil].lastObject;
        PHAssetCollectionChangeRequest * request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [request addAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"保存成功！");
        } else {
            NSLog(@"保存失败");
        }
    }];
}

@end
