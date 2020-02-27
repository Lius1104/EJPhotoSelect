//
//  LSInterceptVideo.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//
//  视频裁剪



#import <UIKit/UIKit.h>
#import <Photos/Photos.h>



@protocol LSInterceptVideoDelegate <NSObject>

- (void)ls_interceptVideoDidCropVideo:(NSString *)assetLocalId;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface LSInterceptVideo : UIViewController

@property (nonatomic, weak) id <LSInterceptVideoDelegate> delegate;

@property (nonatomic, strong, readonly) PHAsset * asset;

@property (nonatomic, assign, readonly) NSTimeInterval duration;

- (instancetype)initWithAsset:(PHAsset *)asset defaultDuration:(NSTimeInterval)duration;

@end

//NS_ASSUME_NONNULL_END
