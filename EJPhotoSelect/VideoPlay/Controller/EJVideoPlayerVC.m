//
//  EJVideoPlayerVC.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/24.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJVideoPlayerVC.h"
#import "EJPlayerControlView.h"
#import <MediaPlayer/MediaPlayer.h>

#import <EJWarningCardView/EJWarningCardView.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

typedef NS_ENUM(NSInteger, EJPlayerState) {
    EJPlayerStateBuffering,  //缓冲中
    EJPlayerStatePlaying,    //播放中
    EJPlayerStateStopped,    //停止播放
    EJPlayerStatePause       //暂停播放
};

typedef NS_ENUM(NSInteger, PanDirection) {
    PanDirectionHorizontalMoved, //横向移动
    PanDirectionVerticalMoved    //纵向移动
};

@interface EJVideoPlayerVC ()<PlayerControlDelegate, EJWarningCardViewDelegate> {
    NSURL * _url;
    PHAsset * _phasset;
}
    
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;
    
@property (nonatomic, strong) EJPlayerControlView * controlView;

@property (nonatomic, strong) EJWarningCardView * cardView;

@property (nonatomic, strong) MPVolumeView * volumeView;

@property (nonatomic, strong) UIActivityIndicatorView * loading;

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@property (nonatomic, weak) NSTimer * timer;

@property (nonatomic, assign) PanDirection panDirection;
@property (nonatomic, assign) EJPlayerState playState;
@property (nonatomic,assign) BOOL isDragSlider;
@property (nonatomic,assign) BOOL isPauseByUser;

@end

@implementation EJVideoPlayerVC
    
- (instancetype)initWithFileUrl:(NSString *)fileUrl {
    self = [super init];
    if (self) {
        if ([fileUrl length] != 0) {
            _url = [[NSURL alloc] initFileURLWithPath:fileUrl];
//            self.playerLayer.player = _player;
        }
    }
    return self;
}
    
- (instancetype)initWithURL:(NSString *)urlString {
    self = [super init];
    if (self) {
        if ([urlString length] > 0) {
            _url = [NSURL URLWithString:urlString];
        }
    }
    return self;
}
    
- (instancetype)initWithAsset:(PHAsset *)phasset {
    self = [super init];
    if (self) {
        _phasset = phasset;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [self removeObserver:self forKeyPath:@"orientation"];
    [_controlView removeObserver:self forKeyPath:@"hidden"];
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    _playerItem = nil;
    _playerLayer = nil;
    _player = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
//    self.fd_interactivePopDisabled = YES;
//    self.fd_prefersNavigationBarHidden = YES;
    
    [self configAssetPlay];
    
    self.orientation = UIInterfaceOrientationPortrait;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.layer addSublayer:self.playerLayer];
        [self.view addSubview:self.controlView];
        [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    });
    if (_phasset == nil) {
        [self setTheProgressOfPlayTime];
        [self addNotifications];
    }
    
    [self addGestures];
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(handleHiddenControlView) userInfo:nil repeats:NO];
    _timer = timer;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadPlayer];
}

- (void)configAssetPlay {
    if (_phasset) {
        if (_phasset && _phasset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionCurrent;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestAVAssetForVideo:_phasset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                _playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
                [self configPlayerItemKVO];
                _player = [AVPlayer playerWithPlayerItem:_playerItem];
                self.playerLayer.player = _player;
                NSString *version= [UIDevice currentDevice].systemVersion;
                if (version.doubleValue >= 10.0 && version.doubleValue < 11.0) {
                    if (@available(iOS 10.0, *)) {
                        _player.automaticallyWaitsToMinimizeStalling = NO;
                    } else {
                        // Fallback on earlier versions
                    }
                }
                [self setTheProgressOfPlayTime];
                [self addNotifications];
            }];
        }
    }
}

- (void)loadPlayer {
    [_controlView play];
    [self.loading startAnimating];
    [self.player play];
    [_controlView pause];
    self.playState = EJPlayerStateBuffering;
    [self.loading stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    [_player pause];
    [_cardView hide];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.view.safeAreaInsets;
    }
    _playerLayer.frame = self.view.bounds;

    self.loading.center = CGPointMake(self.view.width / 2.f, self.view.height / 2.f);

    [_controlView configSubviews:safeInsets];
}

- (void)setHideMore:(BOOL)hideMore {
    _hideMore = hideMore;
    _controlView.hideMore = _hideMore;
}

- (void)configPlayerItemKVO {
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听loadedTimeRanges属性
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is empty
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is good to go again.
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)addGestures {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapView)];
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDirection:)];
    [self.view addGestureRecognizer:pan];
}

- (void)addNotifications {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    // kvo监测 orientation 变化
    [self addObserver:self forKeyPath:@"orientation" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self.controlView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setTheProgressOfPlayTime {
    @weakify(self);
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:NULL usingBlock:^(CMTime time) {
        @strongify(self);
        //如果是拖拽slider中就不执行.
        if (self.isDragSlider) {
            return ;
        }
        float current=CMTimeGetSeconds(time);
        float total = 0;
        AVPlayerItem* currentItem = self.player.currentItem;
        total = CMTimeGetSeconds([currentItem.asset duration]);
        if (isnan(total)) {
            total = 0;
            NSArray* loadedRanges = currentItem.seekableTimeRanges;
            if (loadedRanges.count > 0) {
                CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
                total = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            }
        }
        [self.controlView configProgressByCurrentTime:current totalTime:total];
    } ];
}

- (void)endSlideTheVideo:(CMTime)dragedCMTime {
    [self.player pause];
    [self.loading startAnimating];
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish) {
            // 如果点击了暂停按钮
            [self.loading stopAnimating];
            if (self.isPauseByUser) {
                //NSLog(@"已暂停");
                self.isDragSlider = NO;
                return ;
            }
            if ([_controlView canPlay]) {
                [self.loading stopAnimating];
                [self.player play];
            }
            else {
                [self bufferingSomeSecond];
            }
            self.isDragSlider = NO;
        }];
    }
}

- (void)bufferingSomeSecond {
    
    [self.loading startAnimating];
    //playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        
        if ([_controlView canPlay]) {
            self.playState = EJPlayerStatePlaying;
            [self.player play];
        }
        else
        {
            [self bufferingSomeSecond];
        }
    });
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 隐藏导航栏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations  {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - action
- (void)handleChangeOrientation:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            self.orientation = UIInterfaceOrientationPortrait;
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            self.orientation = UIInterfaceOrientationLandscapeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            self.orientation = UIInterfaceOrientationLandscapeLeft;
        }
            break;
        default:
            break;
    }
}

- (void)handleTapView {
    if (_cardView && _cardView.superview) {
        [_cardView hide];
    } else {
        _controlView.hidden = !_controlView.isHidden;
    }
}

- (void)panDirection:(UIPanGestureRecognizer *)pan {
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self.view];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection           = PanDirectionHorizontalMoved;
                self.isDragSlider = YES;
                
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    [self ej_playerControlDidChangedSlider:self.controlView.videoSlider];
                    
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self ej_playerControlDidEndedTouchSlider:self.controlView.videoSlider];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)verticalMoved:(CGFloat)value {
    // 更改系统的音量
    UISlider *volumeSlider = [self volumeSlider];
    float currnetValue = volumeSlider.value - value / 10000;
    self.volumeView.showsVolumeSlider = YES; // 需要设置 showsVolumeSlider 为 YES
    // 下面两句代码是关键
    [volumeSlider setValue:currnetValue animated:NO];
    [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self.volumeView sizeToFit];
}

- (void)horizontalMoved:(CGFloat)value {
    self.controlView.videoSlider.value += value/10000;
}

- (void)handleHiddenControlView {
    _controlView.hidden = YES;
    if (_cardView && _cardView.superview) {
        [_cardView hide];
    }
}

// 应用退到后台
- (void)appDidEnterBackground {
    [_player pause];
}

// 应用进入前台
- (void)appDidEnterPlayGround {
    //回到前台, 更新屏幕方向
    if (self.playState == EJPlayerStatePlaying) {
        [_player play];
    }
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    NSLog(@"播放完了");
    
    [_player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finish) {
        [self.controlView.videoSlider setValue:0.0 animated:YES];
        [self.controlView configCurrent:0];
    }];
    
    self.playState = EJPlayerStateStopped;
    [self.controlView play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"orientation"]) {
        NSLog(@"orientation change : %@", change);
        NSUInteger current = [change[NSKeyValueChangeNewKey] integerValue];
        _playerLayer.frame = self.view.bounds;
        [_controlView configIsPortrait:(current == UIInterfaceOrientationPortrait)];
//        UIEdgeInsets safeInsets = UIEdgeInsetsZero;
//        if (@available(iOS 11.0, *)) {
//            safeInsets = self.view.safeAreaInsets;
//        }
//        _playerLayer.frame = self.view.bounds;
//        
//        self.loading.center = CGPointMake(self.view.width / 2.f, self.view.height / 2.f);
//        
//        [_controlView configSubviews:safeInsets];
    }
    if (object == self.controlView && [keyPath isEqualToString:@"hidden"]) {
        BOOL hidden = [change[NSKeyValueChangeNewKey] boolValue];
        if (hidden) {
            [_timer invalidate];
            _timer = nil;
        } else {
            NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(handleHiddenControlView) userInfo:nil repeats:NO];
            _timer = timer;
        }
    }
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                self.playState = EJPlayerStatePlaying;
                self.controlView.videoSlider.enabled = YES;
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                [self.loading startAnimating];
                self.controlView.videoSlider.enabled = NO;
            } else {
                [self.loading startAnimating];
                self.controlView.videoSlider.enabled = NO;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.controlView.progressView setProgress:timeInterval / totalDuration animated:NO];
            
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.playState = EJPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp) {
                self.playState = EJPlayerStatePlaying;
            }
        }
    }
}

#pragma mark - PlayerControlDelegate
- (void)ej_playerControlDidClickBack {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)ej_playerControlDidClickChange {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        if (self.orientation == UIInterfaceOrientationPortrait) {
            val = UIInterfaceOrientationLandscapeRight;
        }
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)ej_playerControlDidClickMore {
    if (_cardView && _cardView.superview) {
        return;
    }
    [_timer invalidate];
    _timer = nil;

    _cardView = [[EJWarningCardView alloc] initWithTitleArray:@[@"编辑"] imageArray:nil AtPoint:CGPointMake(self.view.width - 10, CGRectGetMaxY(_controlView.topFrame) + 5) AndSize:CGSizeMake(80, 40) EdgeInset:UIEdgeInsetsZero delegate:self];
    _cardView.isShowBg = NO;
    _cardView.frame = CGRectMake(0, CGRectGetMaxY(_controlView.topFrame), _controlView.width, CGRectGetMinY(_controlView.bottomFrame) - CGRectGetMaxY(_controlView.topFrame));
    _cardView.showFrom = WarningCardShowFromRightTop;
    _cardView.titleFont = [UIFont systemFontOfSize:15];
    _cardView.textColor = [UIColor blackColor];
    _cardView.backgroundImg = [UIImage imageNamed:@"ejtools_video_player_menu"];
    _cardView.contentLeft = 24;
    [_cardView show];
}

- (void)ej_playerControlDidClickPlay:(BOOL)isSelected {
    if (isSelected) {
        self.isPauseByUser = NO;
        [_player play];
        self.playState = EJPlayerStatePlaying;
    } else {
        [_player pause];
        self.isPauseByUser = YES;
        self.playState = EJPlayerStatePause;
    }
}

- (void)ej_playerControlDidBeginTouchSlider:(UISlider *)slider {
    if (slider.isEnabled) {
        self.isDragSlider = YES;
    }
}

- (void)ej_playerControlDidChangedSlider:(UISlider *)slider {
    if (slider.isEnabled) {
        CGFloat total   = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        CGFloat current = total*slider.value;
        [_controlView configCurrent:current];
    }
}

- (void)ej_playerControlDidEndedTouchSlider:(UISlider *)slider {
    if (slider.isEnabled) {
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
        
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        [self endSlideTheVideo:dragedCMTime];
    } else {
        [slider setValue:0 animated:YES];
    }
}

#pragma mark - EJWarningCardViewDelegate
- (void)ejwarningCardView:(EJWarningCardView *)warningView ClickButtonAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(ej_videoPlayerDidClickEdit:)]) {
        [self.delegate ej_videoPlayerDidClickEdit:self];
    }
}

#pragma mark - getter or setter
- (AVPlayerItem *)playerItem {
    if (!_playerItem) {
        _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
        [self configPlayerItemKVO];
    }
    return _playerItem;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        NSString *version= [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 10.0 && version.doubleValue < 11.0) {
            if (@available(iOS 10.0, *)) {
                _player.automaticallyWaitsToMinimizeStalling = NO;
            } else {
                // Fallback on earlier versions
            }
        }
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _playerLayer;
}
    
- (EJPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[EJPlayerControlView alloc] initWithHideMore:NO];
        _controlView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [_controlView configIsPortrait:NO];
        _controlView.delegate = self;
        _controlView.hideMore = _hideMore;
    }
    return _controlView;
}

- (UIActivityIndicatorView *)loading {
    if (!_loading) {
        _loading = [[UIActivityIndicatorView alloc] init];
        _loading.frame = CGRectMake(0, 0, 50, 50);
        _loading.tintColor = [UIColor blackColor];
        [self.view addSubview:_loading];
    }
    return _loading;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.hidden = YES;
        [self.view addSubview:_volumeView];
    }
    return _volumeView;
}

- (UISlider *)volumeSlider {
    UISlider* volumeSlider = nil;
    for (UIView *view in [self.volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            volumeSlider = (UISlider *)view;
            break;
        }
    }
    return volumeSlider;
}
@end
