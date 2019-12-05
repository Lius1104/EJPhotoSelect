//
//  EJCameraShotVC.h
//  TeachingAssistantDemo
//
//  Created by Lius on 2017/7/14.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EJCameraShotView.h"

@class EJCameraShotVC;

@protocol EJCameraShotVCDelegate <NSObject>
@optional

- (void)ej_shotVCDidShot:(NSArray *)assets;

- (void)ej_shotVC:(EJCameraShotVC *)shotVC didCropped:(UIImage *)image;

@end

static NSString * EJCameraShotDismissedNotification = @"EJCameraShotDismissedNotification";//EJCameraShotVC dismiss

typedef enum : NSInteger {
    E_VideoOrientationAll           = 0,
    E_VideoOrientationPortrait      = 1,
    E_VideoOrientationUpsideDown    = 2,
    E_VideoOrientationRight         = 3,
    E_VideoOrientationLeft          = 4,
} E_VideoOrientation;

#define kVideoShotDuration  (60 * 3)

@interface EJCameraShotVC : UIViewController

@property (nonatomic, assign, readonly) EJ_ShotType shotType;

@property (nonatomic, assign, readonly) NSUInteger maxCount;

/**
 是否强制裁剪
 */
@property (nonatomic, assign) BOOL forcedCrop;

/// 图片裁剪比例，默认为 0
@property (nonatomic, assign) CGFloat cropScale;

/// 仅在 shotType 为 EJ_ShotType_Both 是有效，默认为 YES。allowBoth = NO 时，不能再切换照片和视频
@property (nonatomic, assign) BOOL allowBoth;

/// 仅在 shotType 为 EJ_ShotType_Both 且 allowBoth 为 NO 时有效，此时 maxCount 为图片允许拍摄数量, 默认与 maxCount 相同
@property (nonatomic, assign) NSUInteger videoShotCount;
/// 是否直接跳转到裁剪页面，仅在 maxCount == 1 时有效,  default is NO.
@property (nonatomic, assign) BOOL directCrop;
/// 自定义裁剪边框
@property (nonatomic, strong) UIImage * customCropBorder;
@property (nonatomic, strong) UIImage * customLayerImage;
@property (nonatomic, copy) NSString * cropWarningTitle;

- (instancetype)initWithShotTime:(NSTimeInterval)shotTime delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(E_VideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount;

- (instancetype)initWithShotTime:(NSTimeInterval)shotTime shotType:(EJ_ShotType)shotType delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(E_VideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount;

@end
