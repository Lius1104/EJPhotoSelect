//
//  EJCameraShotView.h
//  TeachingAssistantDemo
//
//  Created by Lius on 2017/7/17.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol EJCameraShotDelegate <NSObject>

- (void)ej_cameraShotViewDidClickToClose;

- (void)ej_cameraShotViewDidClickDone;

- (void)ej_cameraShotViewDidClickToChangeDevice;

- (void)ej_cameraShotViewDidClickCameraButtonToTakePhoto;

- (void)ej_cameraShotViewDidClickToRecordVideoWithStart:(BOOL)isStart;

- (void)ej_cameraShotViewDidClickToRerecord;

- (void)ej_cameraShotViewDidClickToSend;

- (void)ej_cameraShotViewDidClickPreviews;

- (BOOL)ej_cameraShotViewCanShot;

- (void)ej_cameraShotViewDidChangeToShotPhoto:(BOOL)isShotPhoto;

@optional

- (void)ej_cameraShotViewDidReachLongestTime;

@end

typedef enum : NSUInteger {
    EJ_ShotType_Both,
    EJ_ShotType_Photo,
    EJ_ShotType_Video,
} EJ_ShotType;

@interface EJCameraShotView : UIView

@property (nonatomic, strong) UIImage * img;

@property (nonatomic, assign) NSUInteger previewCount;

@property (nonatomic, weak) id <EJCameraShotDelegate> delegate;

@property (nonatomic, assign, readonly) EJ_ShotType shotType;

- (instancetype)initWithFrame:(CGRect)frame shotTime:(NSTimeInterval)shotTime shotType:(EJ_ShotType)shotType;

//- (void)showPreviewImage:(BOOL)isShow;

- (void)configOrientation:(AVCaptureVideoOrientation)orientation;

- (void)stopRecordVideo;

@end
