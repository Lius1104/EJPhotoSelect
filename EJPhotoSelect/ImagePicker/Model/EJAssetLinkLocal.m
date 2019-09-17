//
//  EJAssetLinkLocal.m
//  EJPhotoBrowser
//
//  Created by 刘爽 on 2019/8/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJAssetLinkLocal.h"

@implementation EJAssetLinkLocal

- (instancetype)init {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+ (NSString *)rootPath {
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString * rootPath = [docPath stringByAppendingPathComponent:@"AssetEdit"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (result) {
            return rootPath;
        }
        return nil;
    } else {
        return rootPath;
    }
}

- (UIImage *)coverImage {
    if (_coverImage) {
        return _coverImage;
    }
    if (_asset && [_localPath length] > 0) {
        NSString * filePath = [[EJAssetLinkLocal rootPath] stringByAppendingPathComponent:_localPath];
        if (_asset.mediaType == PHAssetMediaTypeImage) {
            return [UIImage imageWithContentsOfFile:filePath];
        } else if (_asset.mediaType == PHAssetMediaTypeVideo) {
            return [UIImage thumbnailImageForVideo:[NSURL fileURLWithPath:filePath] atTime:0.0];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end
