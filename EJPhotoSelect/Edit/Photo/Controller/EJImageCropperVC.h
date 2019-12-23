//
//  EJImageCropperVC.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/6/4.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol EJImageCropperDelegate <NSObject>

- (void)ej_imageCropperVCDidCancel;

- (void)ej_imageCropperVCDidCrop:(UIImage *)image isCrop:(BOOL)isCrop;

@optional
/// 主要用于 某些需要同步的操作上
- (BOOL)ej_imageCropperVCAutoPopAfterCrop;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface EJImageCropperVC : UIViewController

@property (nonatomic, weak) id <EJImageCropperDelegate> delegate;
/// 裁剪比例
@property (nonatomic, assign) CGFloat cropScale;

/// 自定义裁剪边框
@property (nonatomic, strong) UIImage * customCropBorder;
@property (nonatomic, strong) UIImage * customLayerImage;
@property (nonatomic, copy) NSString * warningTitle;

- (instancetype)initWithImage:(UIImage *)image;

@end

//NS_ASSUME_NONNULL_END
