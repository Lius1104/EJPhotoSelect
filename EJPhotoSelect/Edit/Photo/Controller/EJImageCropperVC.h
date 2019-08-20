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

@end

//NS_ASSUME_NONNULL_BEGIN

@interface EJImageCropperVC : UIViewController

@property (nonatomic, weak) id <EJImageCropperDelegate> delegate;

@property (nonatomic, assign) CGFloat cropScale;

- (instancetype)initWithImage:(UIImage *)image;

@end

//NS_ASSUME_NONNULL_END
