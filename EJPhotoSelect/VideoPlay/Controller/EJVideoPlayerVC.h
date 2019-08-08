//
//  EJVideoPlayerVC.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/24.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class EJVideoPlayerVC;
@protocol EJVideoPlayerDelegate <NSObject>

- (void)ej_videoPlayerDidClickEdit:(EJVideoPlayerVC *_Nonnull)videoPlayer;

@end

NS_ASSUME_NONNULL_BEGIN

@interface EJVideoPlayerVC : UIViewController

@property (nonatomic, weak) id <EJVideoPlayerDelegate> delegate;
/**
 使用 沙盒文件路径 创建视频播放器

 @param fileUrl 沙盒文件路径
 @return EJVideoPlayerVC
 */
- (instancetype)initWithFileUrl:(NSString *)fileUrl;
    
/**
 创建视频播放器

 @param urlString 网络路径
 @return EJVideoPlayerVC
 */
- (instancetype)initWithURL:(NSString *)urlString;
    
/**
 创建 视频播放器

 @param phasset 相册视频
 @return EJVideoPlayerVC
 */
- (instancetype)initWithAsset:(PHAsset *)phasset;

@property (nonatomic, assign) BOOL hideMore;

@end

NS_ASSUME_NONNULL_END
