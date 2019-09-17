//
//  LSInterceptVideo.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol LSInterceptVideoDelegate <NSObject>

/**
 获取视频裁剪后的沙盒路径 相对路径

 @param localPath 相对路径，文件名.mp4（文件名为phasset 的 localId，/ 替换成 *）
 */
- (void)ls_interceptVideoDidCropVideo:(NSString *)localPath;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface LSInterceptVideo : UIViewController

@property (nonatomic, weak) id <LSInterceptVideoDelegate> delegate;

@property (nonatomic, strong, readonly) PHAsset * asset;

@property (nonatomic, assign, readonly) NSTimeInterval duration;

- (instancetype)initWithAsset:(PHAsset *)asset defaultDuration:(NSTimeInterval)duration;

@end

//NS_ASSUME_NONNULL_END
