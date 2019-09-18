//
//  EJCameraShotView.m
//  TeachingAssistantDemo
//
//  Created by Lius on 2017/7/17.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import "EJCameraShotView.h"
#import "EJPhotoSelectDefine.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <LSToolsKit/LSToolsKit.h>
#import <EJTools/EJTools.h>



@interface EJCameraShotView ()<UIScrollViewDelegate> {
    NSInteger timeCount;
}

//关闭
@property (nonatomic, strong) LSButton * closeBtn;

//切换摄像头
@property (nonatomic, strong) LSButton * changeDeviceBtn;

@property (nonatomic, strong) UIView * toolView;

//拍摄照片
@property (nonatomic, strong) UIButton * cameraBtn;

@property (nonatomic, strong) UIView * selectedDot;
@property (nonatomic, strong) UIScrollView * selectScroll;
@property (nonatomic, strong) NSArray<UIButton *> * selectItem;

//切换到拍摄视频状态
@property (nonatomic, strong) UIButton * doneBtn;
//视频录制按钮
@property (nonatomic, strong) UIButton *shootBtn;
//视频长度
@property (nonatomic, strong) UILabel *videoTimeLab;
//视频拍摄中图标（默认闪烁动画）
@property (nonatomic, strong) UIView * recordingImg;

@property (nonatomic, strong) UIView * recordingView;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval shotTime;

@property (nonatomic, strong) UILabel * longTimeLabel;

@property (nonatomic, strong) UIImageView * previewImage;

@property (nonatomic, strong) UILabel * previewLabel;

@property (nonatomic, assign) BOOL isShowPreview;

@property (nonatomic, strong) NSArray <UISwipeGestureRecognizer *>* swipeGestures;

@end

@implementation EJCameraShotView

//static const NSTimeInterval animateDuration = 0.75f;

- (void)dealloc {
}

- (instancetype)initWithFrame:(CGRect)frame shotTime:(NSTimeInterval)shotTime shotType:(EJ_ShotType)shotType {
    self = [super initWithFrame:frame];
    if (self) {
        _isShowPreview = NO;
        _shotType = shotType;
        _shotTime = shotTime;
        if (_shotType == EJ_ShotType_Video) {
            _currentType = E_CurrentType_Video;
        } else {
            _currentType = E_CurrentType_Photo;
        }
        [self setupSubviews:frame];
        _longTimeLabel = [[UILabel alloc] init];
        _longTimeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _longTimeLabel.textColor = UIColorHex(ffffff);
        NSString * text = nil;
        if (_shotTime > 60) {
            text = [NSString stringWithFormat:@"最长录制时间%.2f分钟", (_shotTime / 60.f)];
        } else {
            text = [NSString stringWithFormat:@"最长录制时间%02d秒", (int)_shotTime];
        }
        _longTimeLabel.text = text;
        _longTimeLabel.textAlignment = NSTextAlignmentCenter;
        [_longTimeLabel sizeToFit];
        _longTimeLabel.layer.cornerRadius = 4;
        _longTimeLabel.width += 20;
        _longTimeLabel.height += 16;
        _longTimeLabel.centerX = frame.size.width / 2.f;
        _longTimeLabel.bottom = _shootBtn.top - 50;
        [self addSubview:_longTimeLabel];
        _longTimeLabel.hidden = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isShowPreview = NO;
        _shotTime = -1;
        [self setupSubviews:frame];

    }
    return self;
}

- (void)setupSubviews:(CGRect)frame {
    self.backgroundColor = [UIColor clearColor];
    
    timeCount = 0;
    
    _closeBtn = [[LSButton alloc] initWithFrame:CGRectMake([UIView ej_widthAt5ByWidth:28], kToolsStatusHeight + 20, 27, 27)];
    _closeBtn.expendDirection = ExpandingDirectionAll;
    _closeBtn.expendX = 15;
    _closeBtn.expendY = 15;
    [_closeBtn setImage:[UIImage imageNamed:@"ejtools_shot_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(handleCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(26, 26));
        make.top.equalTo(self.mas_top).offset(kToolsStatusHeight + 14);
        make.left.equalTo(self.mas_left).offset(17);
    }];

    _changeDeviceBtn = [[LSButton alloc] initWithFrame:CGRectMake(0, _closeBtn.top, 27, 27)];
    _changeDeviceBtn.expendDirection = ExpandingDirectionAll;
    _changeDeviceBtn.expendX = 10;
    _changeDeviceBtn.expendY = 10;
    [_changeDeviceBtn setImage:[UIImage imageNamed:@"ejtools_shot_switch"] forState:UIControlStateNormal];
    [_changeDeviceBtn addTarget:self action:@selector(handleChangeDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_changeDeviceBtn];
    
    [_changeDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(27, 27));
        make.top.equalTo(self.mas_top).offset(kToolsStatusHeight + 14);
        make.right.equalTo(self.mas_right).offset(-17);
    }];
    
    _toolView = [[UIView alloc] init];
    _toolView.backgroundColor = [UIColorHex(000000) colorWithAlphaComponent:0.5];
    [self addSubview:_toolView];
    
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (_shotType == EJ_ShotType_Both) {
            make.height.mas_equalTo(126);
        } else {
            make.height.mas_equalTo(99);
        }
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.mas_bottom);
        }
    }];
    
    if (_shotType == EJ_ShotType_Both) {
        _selectScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 45, 20)];
        _selectScroll.clipsToBounds = NO;
        _selectScroll.pagingEnabled = YES;
        _selectScroll.showsHorizontalScrollIndicator = NO;
        _selectScroll.delegate = self;
        
        UIButton * photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton setTitle:@"照片" forState:UIControlStateNormal];
        [photoButton setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
#if defined(kMajorColor)
        [photoButton setTitleColor:kMajorColor forState:UIControlStateSelected];
#else
        [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
#endif
        
        photoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        photoButton.frame = CGRectMake(0, 0, 45, 20);
        photoButton.selected = YES;
        [_selectScroll addSubview:photoButton];
        
        UIButton * videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton setTitle:@"视频" forState:UIControlStateNormal];
        [videoButton setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
#if defined(kMajorColor)
        [videoButton setTitleColor:kMajorColor forState:UIControlStateSelected];
#else
        [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
#endif
        videoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        videoButton.frame = CGRectMake(45, 0, 45, 20);
        [_selectScroll addSubview:videoButton];
        _selectScroll.contentSize = CGSizeMake(90, 0);
        
        _selectItem = @[photoButton, videoButton];
        
        [_toolView addSubview:_selectScroll];
        
        _selectedDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
#if defined(kMajorColor)
        _selectedDot.backgroundColor = kMajorColor;
#else
        _selectedDot.backgroundColor = [UIColor whiteColor];
#endif
        _selectedDot.layer.cornerRadius = 2;
        _selectedDot.layer.masksToBounds = YES;
        [_toolView addSubview:_selectedDot];
        
        [_selectScroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_toolView);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(45);
            make.top.equalTo(_toolView);
        }];
        [_selectedDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_toolView);
            make.size.mas_equalTo(CGSizeMake(4, 4));
            make.top.equalTo(_selectScroll.mas_bottom);
        }];
    }
    

    _cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
    _cameraBtn.bottom = frame.size.height - [UIView ej_heightAt5ByHeight:48];
    _cameraBtn.centerX = frame.size.width / 2.f;
    [_cameraBtn setImage:[UIImage imageNamed:@"ejtools_shot_selected"] forState:UIControlStateNormal];
    [_cameraBtn setImage:[UIImage imageNamed:@"ejtools_shot_upload"] forState:UIControlStateSelected];
    [_cameraBtn addTarget:self action:@selector(handleCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:_cameraBtn];
    
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66, 66));
        make.centerX.equalTo(_toolView);
        if (_shotType == EJ_ShotType_Both) {
            make.top.equalTo(_toolView.mas_top).offset(45);
        } else {
            make.centerY.equalTo(_toolView);
        }
    }];
    
    
    _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _doneBtn.right = frame.size.width - [UIView ej_widthAt5ByWidth:40];
    _doneBtn.centerY = _cameraBtn.centerY;
    [_doneBtn setImage:[UIImage imageNamed:@"ejtools_shot_done"] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(handleClickDone:) forControlEvents:UIControlEventTouchUpInside];
    _doneBtn.hidden = YES;
    [_toolView addSubview:_doneBtn];
    
    [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.right.equalTo(_toolView.mas_right).offset(-25);
        make.centerY.equalTo(_cameraBtn.mas_centerY);
    }];
    

    _shootBtn = [[UIButton alloc] initWithFrame:_cameraBtn.frame];
    [_shootBtn setImage:[UIImage imageNamed:@"ejtools_shot_video_selected"] forState:UIControlStateNormal];
    [_shootBtn setImage:[UIImage imageNamed:@"ejtools_shot_video_pressed"] forState:UIControlStateSelected];
    [_shootBtn addTarget:self action:@selector(handleShootAction:) forControlEvents:UIControlEventTouchUpInside];
    _shootBtn.alpha = 0.f;
    [_toolView addSubview:_shootBtn];
    
    [_shootBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_cameraBtn);
    }];
    
    
    _recordingView = [[UIView alloc] initWithFrame:CGRectMake(10, kToolsStatusHeight + 20, 88, 40)];
    _recordingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _recordingView.layer.cornerRadius = 5;
    _recordingView.layer.masksToBounds = YES;
    _recordingView.hidden = YES;
    [self addSubview:_recordingView];
    
    [_recordingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88, 40));
        make.top.equalTo(self.mas_top).offset(20 + kToolsStatusHeight);
        make.left.equalTo(self.mas_left).offset(10);
    }];

    _recordingImg = [[UIView alloc] initWithFrame:CGRectMake(20, kToolsStatusHeight + 20, 8, 8)];
    _recordingImg.backgroundColor = [UIColor redColor];
    _recordingImg.layer.cornerRadius = 4;
    _recordingImg.layer.masksToBounds = YES;
    [_recordingView addSubview:_recordingImg];
    
    [_recordingImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(8, 8));
        make.left.lessThanOrEqualTo(_recordingView.mas_left).offset(15);
        make.left.greaterThanOrEqualTo(_recordingView.mas_left).offset(10);
        make.centerY.equalTo(_recordingView.mas_centerY);
    }];

    _videoTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(_recordingImg.right + 5, kToolsStatusHeight + 20, 62, 20)];
    _videoTimeLab.text = @"00:00";
    _videoTimeLab.font = [UIFont systemFontOfSize:15];
    _videoTimeLab.textColor = UIColorHex(ffffff);
    [_recordingView addSubview:_videoTimeLab];
    
    [_videoTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_recordingImg.mas_right).offset(10);
        make.top.bottom.equalTo(_recordingView);
        make.right.lessThanOrEqualTo(_recordingView.mas_right).offset(-15);
    }];
    
    _previewImage = [[UIImageView alloc] init];
    _previewImage.backgroundColor = UIColorHex(999999);
    _previewImage.layer.cornerRadius = 4;
    _previewImage.layer.masksToBounds = YES;
    _previewImage.contentMode = UIViewContentModeScaleAspectFill;
    _previewImage.hidden = YES;
    _previewImage.userInteractionEnabled = YES;
    @weakify(self);
    UITapGestureRecognizer * tapPreviewImg = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if ([weak_self.delegate respondsToSelector:@selector(ej_cameraShotViewDidClickPreviews)]) {
            [self.delegate ej_cameraShotViewDidClickPreviews];
        }
    }];
    [_previewImage addGestureRecognizer:tapPreviewImg];
    
    [_toolView addSubview:_previewImage];
    
    [_previewImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(48, 48));
        make.left.equalTo(_toolView.mas_left).offset(25);
        make.centerY.equalTo(_toolView);
    }];
    
    _previewLabel = [[UILabel alloc] init];
    _previewLabel.backgroundColor = [UIColor redColor];
    _previewLabel.textColor = UIColorHex(ffffff);
    _previewLabel.font = [UIFont systemFontOfSize:13];
    _previewLabel.layer.cornerRadius = 10;
    _previewLabel.layer.masksToBounds = YES;
    _previewLabel.textAlignment = NSTextAlignmentCenter;
    _previewLabel.hidden = YES;
    _previewLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapPreviewLabel = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        if ([weak_self.delegate respondsToSelector:@selector(ej_cameraShotViewDidClickPreviews)]) {
            [self.delegate ej_cameraShotViewDidClickPreviews];
        }
    }];
    [_previewLabel addGestureRecognizer:tapPreviewLabel];
    
    [_toolView addSubview:_previewLabel];
    
    [_previewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_greaterThanOrEqualTo(20);
        make.left.equalTo(_previewImage.mas_right).offset(-15);
        make.bottom.equalTo(_previewImage.mas_top).offset(12);
    }];
    
    switch (_shotType) {
        case EJ_ShotType_Photo: {
            _cameraBtn.hidden = NO;
            _shootBtn.hidden = YES;
        }
            break;
        case EJ_ShotType_Video: {
            [self handleChangeCurrentShotType];
        }
            break;
        default:
            break;
    }
    
    if (_shotType == EJ_ShotType_Both) {
        // 添加 swipe 手势
        UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:leftSwipe];
        [self addGestureRecognizer:rightSwipe];
        _swipeGestures = @[leftSwipe, rightSwipe];
    }
}

- (void)setImg:(UIImage *)img {
    _img = img;
    if (_img) {
        _previewImage.hidden = NO;
        _previewImage.image = _img;
    } else {
        _previewImage.hidden = YES;
        _previewImage.image = _img;
    }
    _doneBtn.hidden = _previewImage.isHidden;
}

- (void)setPreviewCount:(NSUInteger)previewCount {
    _previewCount = previewCount;
    if (_isShowPreview) {
        _previewLabel.hidden = YES;
    } else {
        if (previewCount == 0) {
            _previewLabel.hidden = YES;
        } else {
            _previewLabel.hidden = NO;
            _previewLabel.text = [NSString stringWithFormat:@"%d", (int)previewCount];
        }
    }
}

- (void)addRecordVideoAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = @1.0f;
    animation.toValue = @0.0f;//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [_recordingImg.layer addAnimation:animation forKey:nil];
}

- (void)configOrientation:(AVCaptureVideoOrientation)orientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGAffineTransform transform = CGAffineTransformIdentity;

        _recordingView.frame = CGRectMake(10, kToolsStatusHeight + 20, 88, 40);
        switch (orientation) {
            case AVCaptureVideoOrientationPortrait:
            case AVCaptureVideoOrientationPortraitUpsideDown: {
                _cameraBtn.transform = CGAffineTransformIdentity;
//                _videoBtn.transform = CGAffineTransformIdentity;
                _doneBtn.transform = CGAffineTransformIdentity;
                
                _recordingView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                _recordingView.layer.position = CGPointZero;
                _recordingView.transform = CGAffineTransformIdentity;
                _recordingView.frame = CGRectMake(10, kToolsStatusHeight + 20, 88, 40);
                
                _recordingView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                _recordingView.layer.position = CGPointZero;
                _recordingView.transform = CGAffineTransformIdentity;
                _recordingView.frame = CGRectMake(10, kToolsStatusHeight + 20, 88, 40);
                
                _previewImage.transform = CGAffineTransformIdentity;
                _previewLabel.transform = CGAffineTransformIdentity;
                [_previewLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_previewImage.mas_right).offset(-10);
                    make.bottom.equalTo(_previewImage.mas_top).offset(10);
                }];
            }
                break;
            case AVCaptureVideoOrientationLandscapeLeft: {
                _cameraBtn.transform = CGAffineTransformRotate(transform, M_PI_2);
//                _videoBtn.transform = CGAffineTransformRotate(transform, M_PI_2);
                _doneBtn.transform = CGAffineTransformRotate(transform, M_PI_2);
                
                
                _recordingView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                _recordingView.layer.position = CGPointZero;
                _recordingView.transform = CGAffineTransformIdentity;
                _recordingView.frame = CGRectMake(10, kToolsStatusHeight + 20, 88, 40);
                
                _recordingView.layer.anchorPoint = CGPointMake(0, 1);
                _recordingView.layer.position = CGPointMake(kToolsStatusHeight + 20 - 7.5, 10 + 12.5);
                _recordingView.transform = CGAffineTransformRotate(transform, M_PI_2);
                
                _previewImage.transform = CGAffineTransformRotate(transform, M_PI_2);
                _previewLabel.transform = CGAffineTransformRotate(transform, M_PI_2);
                [_previewLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_previewImage.mas_right).offset(-10);
                    make.bottom.equalTo(_previewImage.mas_top).offset(60);
                }];
            }
                break;
            case AVCaptureVideoOrientationLandscapeRight: {
                _cameraBtn.transform = CGAffineTransformRotate(transform, -M_PI_2);
//                _videoBtn.transform = CGAffineTransformRotate(transform, -M_PI_2);
                _doneBtn.transform = CGAffineTransformRotate(transform, -M_PI_2);
                
                _recordingView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                _recordingView.layer.position = CGPointZero;
                _recordingView.transform = CGAffineTransformIdentity;
                _recordingView.frame = CGRectMake(10, kToolsStatusHeight + 20, 88, 40);
                
                _recordingView.layer.anchorPoint = CGPointMake(1, 1);
                _recordingView.layer.position = CGPointMake(kToolsStatusHeight + 20 + 7.5, 10 + 12.5);
                _recordingView.transform = CGAffineTransformRotate(transform, -M_PI_2);
                
                _previewImage.transform = CGAffineTransformRotate(transform, -M_PI_2);
                _previewLabel.transform = CGAffineTransformRotate(transform, -M_PI_2);
                [_previewLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_previewImage.mas_right).offset(-60);
                    make.bottom.equalTo(_previewImage.mas_top).offset(10);
                }];
            }
                break;
            default:
                break;
        }
    });
}

- (void)startRecordVideo {
    // 隐藏 scroll，禁用 swipe 手势
    _selectScroll.hidden = YES;
    _selectedDot.hidden = YES;
    [self.swipeGestures enumerateObjectsUsingBlock:^(UISwipeGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled = NO;
    }];
    
    
    _changeDeviceBtn.hidden = YES;
    _closeBtn.hidden = YES;
    _videoTimeLab.text = @"00:00";
    timeCount = 0;
    _recordingView.hidden = NO;
    
    _previewImage.hidden = YES;
    _previewLabel.hidden = YES;
    
    _doneBtn.hidden = YES;
    //更新拍摄时间
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(handleUpdateTime) userInfo:nil repeats:YES];
    [self addRecordVideoAnimation];
}

- (void)stopRecordVideo {
    // 显示 scroll ，开启手势
    _selectScroll.hidden = NO;
    _selectedDot.hidden = NO;
    [self.swipeGestures enumerateObjectsUsingBlock:^(UISwipeGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled = YES;
    }];
    
    _changeDeviceBtn.hidden = NO;
    _shootBtn.selected = NO;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_recordingImg.layer removeAllAnimations];
    _recordingView.hidden = YES;
    if (_isShowPreview) {
        _shootBtn.alpha = 0.f;
        _cameraBtn.alpha = 1.f;
        _cameraBtn.selected = YES;
    } else {
        _doneBtn.hidden = NO;
    }
    _closeBtn.hidden = NO;
    if (_isShowPreview) {
        _previewImage.hidden = NO;
        _previewLabel.hidden = NO;
    }
}

- (void)setUpAllowBoth {
    if (_shotType == EJ_ShotType_Both) {
        _selectScroll.hidden = !_allowBoth;
        _selectedDot.hidden = !_allowBoth;
        [_swipeGestures enumerateObjectsUsingBlock:^(UISwipeGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.enabled = _allowBoth;
        }];
    }
}

- (void)resetSubviews {
    _selectScroll.hidden = NO;
    _selectedDot.hidden = NO;
    [_swipeGestures enumerateObjectsUsingBlock:^(UISwipeGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enabled = YES;
    }];
}

#pragma mark - action
- (void)handleCloseAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(ej_cameraShotViewDidClickToClose)]) {
        [_delegate ej_cameraShotViewDidClickToClose];
    }
}

- (void)handleChangeDeviceAction:(UIButton *)sender {
    //可以添加动画效果transfram
    if ([_delegate respondsToSelector:@selector(ej_cameraShotViewDidClickToChangeDevice)]) {
        [_delegate ej_cameraShotViewDidClickToChangeDevice];
    }
}

- (void)handleCameraAction:(UIButton *)sender {
    [self setUpAllowBoth];
    if (sender.isSelected == NO) {
        BOOL isCanShot = YES;
        if ([self.delegate respondsToSelector:@selector(ej_cameraShotViewCanShot)]) {
            isCanShot = [self.delegate ej_cameraShotViewCanShot];
        }
        if (isCanShot == NO) {
            return;
        }
        if (_isShowPreview) {
            sender.selected = YES;
        }
        if ([_delegate respondsToSelector:@selector(ej_cameraShotViewDidClickCameraButtonToTakePhoto)]) {
            [_delegate ej_cameraShotViewDidClickCameraButtonToTakePhoto];
        }
        if (_isShowPreview) {
            _doneBtn.hidden = YES;
        }
    } else {
        sender.enabled = NO;
        if ([_delegate respondsToSelector:@selector(ej_cameraShotViewDidClickToSend)]) {
            [_delegate ej_cameraShotViewDidClickToSend];
        }
    }
}

- (void)handleShootAction:(UIButton *)sender {
    
    if (sender.isSelected == NO) {
        BOOL isCanShot = YES;
        if ([self.delegate respondsToSelector:@selector(ej_cameraShotViewCanShot)]) {
            isCanShot = [self.delegate ej_cameraShotViewCanShot];
        }
        if (isCanShot == NO) {
            return;
        }
    }
    sender.selected = !sender.isSelected;
    //结束/开始视频拍摄
    if (sender.isSelected) {//开始拍摄
        [self startRecordVideo];
    } else {
        [self stopRecordVideo];
    }
    
    [self setUpAllowBoth];
    
    if ([_delegate respondsToSelector:@selector(ej_cameraShotViewDidClickToRecordVideoWithStart:)]) {
        [_delegate ej_cameraShotViewDidClickToRecordVideoWithStart:sender.isSelected];
    }
}

- (void)handleUpdateTime {
    timeCount ++;
    //秒
    int second = (int)timeCount % 60;
    //分
    int minute = (int)timeCount / 60;
    _videoTimeLab.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    if (_shotTime > 0) {
        if (timeCount >= _shotTime) {
            [_timer invalidate];
            _timer = nil;
            //拍摄 最长时间 到了
            [self handleShootAction:_shootBtn];
            _longTimeLabel.hidden = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _longTimeLabel.hidden = YES;
            });
            if ([self.delegate respondsToSelector:@selector(ej_cameraShotViewDidReachLongestTime)]) {
                [self.delegate ej_cameraShotViewDidReachLongestTime];
            }
        }
    }
}

- (void)handleClickDone:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ej_cameraShotViewDidClickDone)]) {
        [self.delegate ej_cameraShotViewDidClickDone];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
            NSLog(@"手指从右往左");
            // 判断当前 是照片还是视频
            // 如果 是 视频 则 不动 如果是 照片 则切换到 视频
            if (_currentType == E_CurrentType_Photo) {
                _currentType = E_CurrentType_Video;
                [self handleChangeCurrentShotType];
            }
        }
        if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"手指从左往右");
            // 判断当前 是照片还是视频
            // 如果 是 照片 则 不动 如果是 视频 则切换到 照片
            if (_currentType == E_CurrentType_Video) {
                _currentType = E_CurrentType_Photo;
                [self handleChangeCurrentShotType];
            }
        }
    }
}

- (void)handleChangeCurrentShotType {
    //动画隐藏／显示对应按钮
    _changeDeviceBtn.hidden = NO;
    if (_currentType == E_CurrentType_Video) {
        _selectScroll.contentOffset = CGPointMake(45, 0);
    } else {
        _selectScroll.contentOffset = CGPointMake(0, 0);
    }
    [self.selectItem enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == _selectScroll.contentOffset.x / 45) {
            obj.selected = YES;
        } else {
            obj.selected = NO;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(ej_cameraShotViewDidChangeToShotPhoto:)]) {
        [self.delegate ej_cameraShotViewDidChangeToShotPhoto:(_currentType == E_CurrentType_Photo)];
    }
    if (_currentType == E_CurrentType_Video) {
        _cameraBtn.alpha = 0.f;
        _shootBtn.alpha = 1.f;
    } else {
        _cameraBtn.alpha = 1.f;
        _shootBtn.alpha = 0.f;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 计算滚动到哪一页
    NSUInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (index != _currentType) {
        _currentType = (E_CurrentType)index;
        [self handleChangeCurrentShotType];
    }
}

#pragma mark - getter or setter
- (void)setAllowBoth:(BOOL)allowBoth {
    _allowBoth = allowBoth;
//    if (_shotType == EJ_ShotType_Both) {
//        _selectScroll.hidden = !_allowBoth;
//        _selectedDot.hidden = !_allowBoth;
//        [_swipeGestures enumerateObjectsUsingBlock:^(UISwipeGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            obj.enabled = _allowBoth;
//        }];
//    }
}

@end
