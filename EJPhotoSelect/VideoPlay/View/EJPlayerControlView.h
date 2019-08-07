//
//  EJPlayerControlView.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/24.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerControlDelegate <NSObject>

- (void)ej_playerControlDidClickBack;

- (void)ej_playerControlDidClickChange;

- (void)ej_playerControlDidClickMore;

- (void)ej_playerControlDidClickPlay:(BOOL)isSelected;

- (void)ej_playerControlDidBeginTouchSlider:(UISlider *)slider;

- (void)ej_playerControlDidChangedSlider:(UISlider *)slider;

- (void)ej_playerControlDidEndedTouchSlider:(UISlider *)slider;

@end

@interface EJPlayerControlView : UIView

@property (nonatomic, assign, getter=isHideMore) BOOL hideMore;

@property (nonatomic, assign, readonly) CGRect topFrame;
@property (nonatomic, assign, readonly) CGRect bottomFrame;

- (instancetype)initWithHideMore:(BOOL)hideMore;

@property (nonatomic, weak) id <PlayerControlDelegate> delegate;

@property (nonatomic, strong) UISlider * videoSlider;
@property (nonatomic, strong) UIProgressView * progressView;

- (void)configSubviews:(UIEdgeInsets)safeInsets;

- (void)configIsPortrait:(BOOL)isPortrait;

- (void)configProgressByCurrentTime:(float)current totalTime:(float)total;

- (void)configCurrent:(float)current;

- (BOOL)canPlay;

- (void)play;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
