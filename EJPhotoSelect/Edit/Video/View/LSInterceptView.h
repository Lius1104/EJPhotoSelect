//
//  LSInterceptView.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSInterceptViewDelegate <NSObject>

- (void)ls_interceptViewDidChanged:(CMTime)time;

- (void)ls_interceptViewDidEndChangeTime:(CMTime)time duration:(CGFloat)duration;

- (void)ls_interceptViewDidSeekToTime:(CMTime)time;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface LSInterceptView : UIView

@property (nonatomic, assign, readonly) double timeUnit;
@property (nonatomic, assign) CGRect validRect;

@property (nonatomic, strong) AVAsset * asset;

@property (nonatomic, weak) id <LSInterceptViewDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset maximumDuration:(NSTimeInterval)duration;

- (CMTime)getStartTime;

- (CMTime)getEndTime;

- (void)startProgress;

- (void)stopProgress;

@end

//NS_ASSUME_NONNULL_END
