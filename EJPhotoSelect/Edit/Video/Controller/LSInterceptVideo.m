//
//  LSInterceptVideo.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSInterceptVideo.h"
#import "LSInterceptView.h"
#import "LSSaveToAlbum.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "EJPhotoSelectDefine.h"
#import "EJAssetLinkLocal.h"

@interface LSInterceptVideo ()<LSInterceptViewDelegate>

@property (nonatomic, strong) UIView * playerView;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;

@property (nonatomic, strong) UILabel * targetDurationLabel;

@property (nonatomic, strong) LSInterceptView * operationView;

@property (nonatomic, strong) UIButton * cancelButton;

@property (nonatomic, strong) UIButton * doneButton;

@property (nonatomic, strong) AVAsset * avasset;

@property (nonatomic, strong) PHVideoRequestOptions * videoOptions;

@property (nonatomic, weak) NSTimer * timer;
@property (nonatomic, assign) CMTime startRange;
@property (nonatomic, assign) NSTimeInterval playDuration;

@property (nonatomic, strong) MBProgressHUD * hud;

@end

@implementation LSInterceptVideo

- (void)dealloc {
    if (_timer) {
        [self stopTimer];
    }
    _playerItem = nil;
    _playerLayer = nil;
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithAsset:(PHAsset *)asset defaultDuration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        _asset = asset;
        NSTimeInterval targetDuration = duration <= 0 ? 180 : duration;
        if (_asset.duration < targetDuration) {
            _duration = _asset.duration;
        } else {
            _duration = targetDuration;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;

    self.view.backgroundColor = [UIColor blackColor];
    
    [self configSubivews];
    
    [self.playerView.layer addSublayer:self.playerLayer];
    
    [self.view layoutIfNeeded];
    CGRect bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kToolsStatusHeight - 114 - kToolsBottomSafeHeight - 60 - 6 - [UIFont systemFontOfSize:13].lineHeight);
    _playerLayer.frame = bounds;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    // phasset转化成 avasset
    __weak typeof(self) weak_self = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:self.videoOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
            weak_self.player = [[AVPlayer alloc] initWithPlayerItem:weak_self.playerItem];
            weak_self.playerLayer.player = weak_self.player;
            weak_self.avasset = asset;
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)configSubivews {
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(3);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(11);
        } else {
            make.top.equalTo(self.view.mas_top).offset(11);
        }
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(37);
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cancelButton);
        make.size.equalTo(self.cancelButton);
        make.right.equalTo(self.view.mas_right).offset(-7);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelButton.mas_bottom).offset(12);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [self.targetDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerView.mas_bottom).offset(12);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(ceil([UIFont systemFontOfSize:13].lineHeight));
        
    }];
    
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_targetDurationLabel.mas_bottom).offset(6);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-58);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-58);
        }
        make.height.mas_equalTo(40);
    }];
    
    
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}

- (void)startTimer {
    [self stopTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_playDuration target:self selector:@selector(handlePlayPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    [self.playerLayer.player pause];
}

- (void)cropVideo {
    if (_hud) {
        [_hud hideAnimated:YES];
        _hud = nil;
    }
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CMTime end = [_operationView getEndTime];
    [[PHImageManager defaultManager] requestExportSessionForVideo:_asset options:self.videoOptions exportPreset:AVAssetExportPresetPassthrough resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        CMTimeRange range = CMTimeRangeMake(self->_startRange, end);
        exportSession.timeRange = range;
        exportSession.shouldOptimizeForNetworkUse = YES;
        NSString * localPath = [NSString stringWithFormat:@"%@.mp4", [_asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"*"]];
        NSString *filePath = [[EJAssetLinkLocal rootPath] stringByAppendingPathComponent:localPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    break;
                case AVAssetExportSessionStatusWaiting:
                    break;
                case AVAssetExportSessionStatusExporting:
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->_hud hideAnimated:YES];
                        if (self.presentingViewController) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        if ([self.delegate respondsToSelector:@selector(ls_interceptVideoDidCropVideo:)]) {
                            [self.delegate ls_interceptVideoDidCropVideo:localPath];
                        }
                    });
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                    self->_hud.label.text = @"裁剪失败，请重试";
                    [self->_hud hideAnimated:YES afterDelay:1.5];
                    break;
                case AVAssetExportSessionStatusCancelled:
                    self->_hud.label.text = @"裁剪被取消，请重试";
                    [self->_hud hideAnimated:YES afterDelay:1.5];
                    break;
                default:
                    break;
            }
        }];
    }];
}

#pragma mark - action
- (void)handleClickCancelButton {
    [self stopTimer];
    [_operationView stopProgress];
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleClickDoneButton {
    [self stopTimer];
    [_operationView stopProgress];
    CGFloat end = CMTimeGetSeconds([_operationView getEndTime]);
    CGFloat start = CMTimeGetSeconds([_operationView getStartTime]);
    if (start == 0 && _duration == (end - start) && _asset.duration == _duration) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if ([self.delegate respondsToSelector:@selector(ls_interceptVideoDidCropVideo:)]) {
            [self.delegate ls_interceptVideoDidCropVideo:nil];
        }
    } else {
        //裁剪当前视频
        [self cropVideo];
    }
}

- (void)handlePlayPartVideo:(NSTimer *)timer {
    [self.player seekToTime:_startRange toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

- (void)handleApplicationWillResignActive {
    [_operationView stopProgress];
    [self stopTimer];
}

- (void)handleApplicationDidBecomActive {
    [_operationView startProgress];
    [self startTimer];
}

#pragma mark - LSInterceptViewDelegate
- (void)ls_interceptViewDidChanged:(CMTime)time {
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self stopTimer];
    [self.player pause];
    
    CGFloat end = CMTimeGetSeconds([_operationView getEndTime]);
    CGFloat start = CMTimeGetSeconds([_operationView getStartTime]);
    CGFloat result = ceil(end - start);
    _targetDurationLabel.text = [NSString stringWithFormat:@"%d秒", (int)result];
}

- (void)ls_interceptViewDidEndChangeTime:(CMTime)time duration:(CGFloat)duration {
    _startRange = time;
    _playDuration = duration;
    [self startTimer];
}

- (void)ls_interceptViewDidSeekToTime:(CMTime)time {
    [self stopTimer];
    [self.playerLayer.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - getter or setter
- (void)setAvasset:(AVAsset *)avasset {
    _avasset = avasset;
    _startRange = CMTimeMakeWithSeconds(0, avasset.duration.timescale);
    _operationView.asset = avasset;
    _playDuration = 0;
    if (_asset.duration < _duration) {
        _playDuration = _asset.duration;
    } else {
        _playDuration = _duration;
    }
    
    CGFloat end = CMTimeGetSeconds([_operationView getEndTime]);
    CGFloat start = CMTimeGetSeconds([_operationView getStartTime]);
    CGFloat result = ceil(end - start);
    _targetDurationLabel.text = [NSString stringWithFormat:@"%d秒", (int)result];
    
    [self startTimer];
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setImage:[UIImage imageNamed:@"ejtools_interceptVideo_back"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(handleClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setImage:[UIImage imageNamed:@"ejtools_intercept_done"] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(handleClickDoneButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_doneButton];
    }
    return _doneButton;
}

- (UILabel *)targetDurationLabel {
    if (!_targetDurationLabel) {
        _targetDurationLabel = [[UILabel alloc] init];
        _targetDurationLabel.font = [UIFont systemFontOfSize:13];
        _targetDurationLabel.textColor = [UIColor whiteColor];
        _targetDurationLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:_targetDurationLabel];
    }
    return _targetDurationLabel;
}

- (LSInterceptView *)operationView {
    if (!_operationView) {
        _operationView = [[LSInterceptView alloc] initWithAsset:nil maximumDuration:_duration];
//        _operationView.frame =  CGRectMake(0, 0, kScreenWidth, 40);
        _operationView.backgroundColor = [UIColor blackColor];
        _operationView.delegate = self;
        [self.view addSubview:_operationView];
    }
    return _operationView;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
        _playerView.layer.masksToBounds = YES;
        [self.view addSubview:_playerView];
        [self.view sendSubviewToBack:_playerView];
    }
    return _playerView;
}

- (PHVideoRequestOptions *)videoOptions {
    if (!_videoOptions) {
        _videoOptions = [[PHVideoRequestOptions alloc] init];
        _videoOptions.version = PHVideoRequestOptionsVersionCurrent;
        _videoOptions.networkAccessAllowed = YES;
    }
    return _videoOptions;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _playerLayer;
}

@end
