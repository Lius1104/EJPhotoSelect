//
//  EJPlayerControlView.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/24.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJPlayerControlView.h"
#import "EJPhotoSelectDefine.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

@interface EJPlayerControlView ()

@property (nonatomic, strong) UIView * topControl;
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * changeButton;
@property (nonatomic, strong) UIButton * moreButton;

@property (nonatomic, strong) UIView * bottomControl;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UILabel * currentTimeLabel;
@property (nonatomic, strong) UILabel * totalTimeLabel;



//@property (nonatomic, assign) UIEdgeInsets safeInsets;

@end

@implementation EJPlayerControlView

#define kTopControlHeight       44
#define kBottomControlHeight    50

- (instancetype)initWithHideMore:(BOOL)hideMore {
    self = [super init];
    if (self) {
        _hideMore = hideMore;
        [self initSubviews];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hideMore = NO;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
//    _safeInsets = UIEdgeInsetsZero;
    [self addSubview:self.topControl];
    [self addSubview:self.bottomControl];
    
    [_topControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(kToolsNavStatusHeight);
    }];
    [_bottomControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(kBottomControlHeight + kToolsBottomSafeHeight);
    }];
}

- (void)configSubviews:(UIEdgeInsets)safeInsets {
    // config top control
    _topFrame = CGRectMake(0, 0, self.bounds.size.width, kToolsNavStatusHeight);
    [self configTopSubviews];
    // config bottom control
    _bottomFrame = CGRectMake(0, self.bounds.size.height - (kBottomControlHeight + kToolsBottomSafeHeight), self.bounds.size.width, kBottomControlHeight + kToolsBottomSafeHeight);
    [self configBottomSubviews];
}

- (void)configTopSubviews {
    if (_hideMore) {
        _moreButton.hidden = YES;
        [_moreButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.left.equalTo(_changeButton.mas_right).offset(0);
        }];
    } else {
        _moreButton.hidden = NO;
        [_moreButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(35);
            make.left.equalTo(_changeButton.mas_right).offset(10);
        }];
    }
}

- (void)configBottomSubviews {
}

- (void)configIsPortrait:(BOOL)isPortrait {
    _changeButton.selected = !isPortrait;
}

- (void)setHideMore:(BOOL)hideMore {
    if (_hideMore != hideMore) {
        _hideMore = hideMore;
        _moreButton.hidden = _hideMore;
        // 调整 frame
        [self configSubviews:UIEdgeInsetsZero];
    }
}

- (void)configProgressByCurrentTime:(float)current totalTime:(float)total {
    if (current) {
        [_videoSlider setValue:(current/total) animated:YES];
    }
    
    //秒数
    NSInteger proSec = (NSInteger)current%60;
    //分钟
    NSInteger proMin = (NSInteger)current/60;
    
    //总秒数和分钟
    NSInteger durSec = (NSInteger)(total)%60;
    NSInteger durMin = (NSInteger)(total)/60;
    _currentTimeLabel.text    = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    _totalTimeLabel.text      = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}

- (void)configCurrent:(float)current {
    //秒数
    NSInteger proSec = (NSInteger)current%60;
    //分钟
    NSInteger proMin = (NSInteger)current/60;
    _currentTimeLabel.text    = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
}

- (BOOL)canPlay {
    return (_progressView.progress - _videoSlider.value) > 0.01;
}

- (void)play {
    _playButton.selected = NO;
}

- (void)pause {
    _playButton.selected = YES;
}

#pragma mark - action
- (void)handleClickBackButton {
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidClickBack)]) {
        [self.delegate ej_playerControlDidClickBack];
    }
}

- (void)handleClickChangeButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidClickChange)]) {
        [self.delegate ej_playerControlDidClickChange];
    }
}

- (void)handleClickMoreButton {
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidClickMore)]) {
        [self.delegate ej_playerControlDidClickMore];
    }
}

- (void)handleClickPlayButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidClickPlay:)]) {
        [self.delegate ej_playerControlDidClickPlay:sender.isSelected];
    }
}

- (void)handleSliderTouchBegan:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidBeginTouchSlider:)]) {
        [self.delegate ej_playerControlDidBeginTouchSlider:slider];
    }
}

- (void)handleSliderValueChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidChangedSlider:)]) {
        [self.delegate ej_playerControlDidChangedSlider:slider];
    }
}

- (void)handleSliderTouchEnded:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(ej_playerControlDidEndedTouchSlider:)]) {
        [self.delegate ej_playerControlDidEndedTouchSlider:slider];
    }
}

- (void)handleTapVideoSlider:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint touchPoint = [gesture locationInView:_videoSlider];
        CGFloat value = (_videoSlider.maximumValue - _videoSlider.minimumValue) * (touchPoint.x / _videoSlider.frame.size.width);
        [_videoSlider setValue:value animated:YES];
    }
}

#pragma mark - getter or setter
- (UIView *)topControl {
    if (!_topControl) {
        _topControl = [[UIView alloc] init];
        _topControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        [_topControl addSubview:self.backButton];
        [_topControl addSubview:self.titleLabel];
        [_topControl addSubview:self.changeButton];
        [_topControl addSubview:self.moreButton];
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_topControl.mas_bottom);
            make.width.mas_equalTo(35);
            make.height.mas_equalTo(kTopControlHeight);
            make.left.equalTo(_topControl.mas_left).offset(10);
        }];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_topControl.mas_bottom);
            make.height.mas_equalTo(kTopControlHeight);
            make.left.equalTo(_backButton.mas_right).offset(10);
        }];
        
        [_changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_topControl.mas_bottom);
            make.width.mas_equalTo(35);
            make.height.mas_equalTo(kTopControlHeight);
            make.left.equalTo(_titleLabel.mas_right).offset(10);
        }];
        
        [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_topControl.mas_bottom);
            make.width.mas_equalTo(35);
            make.height.mas_equalTo(kTopControlHeight);
            make.left.equalTo(_changeButton.mas_right).offset(10);
            make.right.equalTo(_topControl.mas_right).offset(-10);
        }];
    }
    return _topControl;
}

- (UIView *)bottomControl {
    if (!_bottomControl) {
        _bottomControl = [[UIView alloc] init];
        _bottomControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        [_bottomControl addSubview:self.playButton];
        [_bottomControl addSubview:self.currentTimeLabel];
        [_bottomControl addSubview:self.progressView];
        [_bottomControl addSubview:self.videoSlider];
        [_bottomControl addSubview:self.totalTimeLabel];
        
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bottomControl.mas_top);
            make.width.mas_equalTo(35);
            make.height.mas_equalTo(kBottomControlHeight);
            make.left.equalTo(_bottomControl.mas_left).offset(15);
        }];
        
        [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_playButton.mas_right).offset(10);
            make.top.equalTo(_bottomControl.mas_top);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(kBottomControlHeight);
        }];
        
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_currentTimeLabel.mas_right).offset(10);
            make.centerY.equalTo(_playButton.mas_centerY);
            make.height.mas_equalTo(1.5);
        }];
        
        [_videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_progressView);
        }];
        
        [_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_progressView.mas_right).offset(10);
            make.top.equalTo(_bottomControl.mas_top);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(kBottomControlHeight);
            make.right.equalTo(_bottomControl.mas_right).offset(-15);
        }];
    }
    return _bottomControl;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 35, kTopControlHeight);
        [_backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(handleClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.frame = CGRectMake(0, 0, 0, kTopControlHeight);
        
//        _titleLabel.text = @"未命名";
    }
    return _titleLabel;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.frame = CGRectMake(0, 0, 35, kTopControlHeight);
        [_changeButton setImage:[UIImage imageNamed:@"横屏"] forState:UIControlStateNormal];
        [_changeButton setImage:[UIImage imageNamed:@"竖屏"] forState:UIControlStateSelected];
        [_changeButton addTarget:self action:@selector(handleClickChangeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectMake(0, 0, 35, kTopControlHeight);
        [_moreButton setImage:[UIImage imageNamed:@"TR_detail_More"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(handleClickMoreButton) forControlEvents:UIControlEventTouchUpInside];
        
        _moreButton.hidden = _hideMore;
    }
    return _moreButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, kBottomControlHeight)];
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(handleClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, kBottomControlHeight)];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:13];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, kBottomControlHeight)];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:13];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 0, 1.5)];
        _progressView.progressTintColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _progressView.trackTintColor       = [UIColor clearColor];
    }
    return _progressView;
}

- (UISlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc] init];
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        [_videoSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        
        [_videoSlider addTarget:self action:@selector(handleSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        
        //slider滑动中事件
        [_videoSlider addTarget:self action:@selector(handleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        //slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(handleSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UITapGestureRecognizer * tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapVideoSlider:)];
        [_videoSlider addGestureRecognizer:tapSlider];
    }
    return _videoSlider;
}

@end
