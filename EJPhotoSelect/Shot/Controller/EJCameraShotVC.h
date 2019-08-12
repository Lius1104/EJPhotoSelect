//
//  EJCameraShotVC.h
//  TeachingAssistantDemo
//
//  Created by Lius on 2017/7/14.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EJCameraShotView.h"

@protocol EJCameraShotVCDelegate <NSObject>
@optional

- (void)ej_shotVCDidShot:(NSArray *)assets;

@end

static NSString * EJCameraShotDismissedNotification = @"EJCameraShotDismissedNotification";//EJCameraShotVC dismiss

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

- (instancetype)initWithShotTime:(NSTimeInterval)shotTime delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(AVCaptureVideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount;

- (instancetype)initWithShotTime:(NSTimeInterval)shotTime shotType:(EJ_ShotType)shotType delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(AVCaptureVideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount;

@end
