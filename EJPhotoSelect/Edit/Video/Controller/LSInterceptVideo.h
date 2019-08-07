//
//  LSInterceptVideo.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSInterceptVideoDelegate <NSObject>

- (void)ls_interceptVideoDidCropVideo:(NSString *)assetLocalId;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface LSInterceptVideo : UIViewController

@property (nonatomic, weak) id <LSInterceptVideoDelegate> delegate;

@property (nonatomic, strong, readonly) PHAsset * asset;

@property (nonatomic, assign, readonly) NSUInteger duration;

- (instancetype)initWithAsset:(PHAsset *)asset defaultDuration:(NSUInteger)duration;

@end

//NS_ASSUME_NONNULL_END
