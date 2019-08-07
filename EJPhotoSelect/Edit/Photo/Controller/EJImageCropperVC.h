//
//  EJImageCropperVC.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/6/4.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJViewController.h"

@protocol EJImageCropperDelegate <NSObject>

- (void)ej_imageCropperVCDidCancel;

- (void)ej_imageCropperVCDidCrop:(UIImage *)image;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface EJImageCropperVC : EJViewController

@property (nonatomic, weak) id <EJImageCropperDelegate> delegate;

@property (nonatomic, assign) CGFloat cropScale;

- (instancetype)initWithImage:(UIImage *)image;

@end

//NS_ASSUME_NONNULL_END
