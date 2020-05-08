//
//  EJImageCropperVC.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/6/4.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImageCropperVC.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <JPImageresizerView/JPImageresizerView.h>
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <LSToolsKit/LSToolsKit.h>

@interface EJImageCropperVC ()

@property (nonatomic, strong) UIImage * image;

@property (nonatomic, strong) JPImageresizerView * imageresizerView;

@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIButton * cancelBtn;
@property (nonatomic, strong) UIButton * doneBtn;
@property (nonatomic, strong) UIButton * rotateBtn;

@property (nonatomic, strong) UILabel * warningLabel;

@property (nonatomic, strong) UIImageView * customImageView;

@property (nonatomic, assign) BOOL isAddObserver;
@property (nonatomic, weak) UIImageView * borderImage;

@end

@implementation EJImageCropperVC

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _cropScale = 0;
        _image = image;
        _isAddObserver = NO;
    }
    return self;
}

- (void)dealloc {
    if (_isAddObserver) {
        for (UIView * subview in _imageresizerView.frameView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView * imageView = (UIImageView *)subview;
                if ([imageView.image.accessibilityIdentifier isEqualToString:@"customCropBorder"]) {
                    [imageView removeObserver:self forKeyPath:@"frame"];
                    break;
                }
            }
        }
    }
}

- (void)viewDidLoad {
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorHex(ffffff);
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_bottomView];
    
    UIView * topLine = [[UIView alloc] init];
    topLine.backgroundColor = UIColorHex(2f2f2f);
    [_bottomView addSubview:topLine];
    
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(56);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(_bottomView);
        make.height.mas_equalTo(0.5);
    }];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setImage:[UIImage imageNamed:@"ejtools_crop_cancel"] forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(handleClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setImage:[UIImage imageNamed:@"ejtools_crop_done"] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneBtn setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
    
    _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rotateBtn setImage:[UIImage imageNamed:@"ejtools_crop_rotate"] forState:UIControlStateNormal];
    [_rotateBtn addTarget:self action:@selector(handleClickRotateButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_rotateBtn];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.centerY.equalTo(_bottomView);
    }];
    [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.size.equalTo(_cancelBtn);
        make.bottom.equalTo(_cancelBtn.mas_bottom);
    }];
    
    [_rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 32));
        make.center.equalTo(_bottomView);
    }];
    
    if (_customCropBorder) {
        _customCropBorder.accessibilityIdentifier = @"customCropBorder";
    }
    
    @weakify(self);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 0, (56 + 24), 0);
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:_image make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(contentInsets);
        if (weak_self.customCropBorder) {
            configure.jp_borderImage(weak_self.customCropBorder);
            configure.jp_borderImageRectInset(CGPointMake(-2, -2));
        }
        configure.jp_animationCurve(JPAnimationCurveLinear);
    }];
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @strongify(self);
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        self.doneBtn.enabled = enabled;
        self.rotateBtn.enabled = enabled;
    }];
    imageresizerView.resizeWHScale = _cropScale;
    imageresizerView.frameType = JPClassicFrameType;
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    
    if (_customCropBorder && _customLayerImage && _cropScale != 0) {
        _customImageView = [[UIImageView alloc] initWithImage:self.customLayerImage];
        _customImageView.contentMode = UIViewContentModeScaleAspectFill;
        _customImageView.clipsToBounds = YES;
        for (UIView * subview in _imageresizerView.frameView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView * imageView = (UIImageView *)subview;
                if ([imageView.image.accessibilityIdentifier isEqualToString:@"customCropBorder"]) {
                    [imageView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
                    _isAddObserver = YES;
                    _borderImage = imageView;
                    [imageView addSubview:_customImageView];
                    [_customImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.center.equalTo(imageView);
                        make.width.equalTo(imageView.mas_width).multipliedBy(0.66);
                        make.height.equalTo(imageView.mas_height).multipliedBy(0.66);
                    }];
                    break;
                }
            }
        }
        
        
    }
    
    if ([_warningTitle length] > 0) {
        _warningLabel = [[UILabel alloc] init];
        _warningLabel.textColor = UIColorHex(FFFEFE);
        _warningLabel.font = [UIFont systemFontOfSize:14];
        _warningLabel.textAlignment = NSTextAlignmentCenter;
        _warningLabel.text = _warningTitle;
        [_imageresizerView addSubview:_warningLabel];
        CGFloat height = (kScreenWidth - 20) / _cropScale;
        CGFloat centerY = CGRectGetMidY(_imageresizerView.frameView.frame);
        CGFloat top = centerY + height / 2 + 20;
        [_warningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imageresizerView.mas_left).offset(10);
            make.centerX.equalTo(_imageresizerView);
            make.top.equalTo(_imageresizerView.mas_top).offset(top);
            make.height.mas_equalTo(17);
        }];
    }
    
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.frame = [UIScreen mainScreen].bounds;
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setCropScale:(CGFloat)cropScale {
    _cropScale = cropScale;
    if (self.imageresizerView) {
        self.imageresizerView.resizeWHScale = _cropScale;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        NSLog(@"frame : %@", NSStringFromCGRect(_borderImage.frame));
        if (_customImageView) {
            _customImageView.width = _borderImage.width * 0.66;
            _customImageView.height = _borderImage.height * 0.66;
        }
    }
}

#pragma mark - action
- (void)handleClickCancelButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCDidCancel)]) {
        [self.delegate ej_imageCropperVCDidCancel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickDoneButton:(UIButton *)sender {
    sender.enabled = NO;
    
    @weakify(self);
    // 以原图尺寸进行裁剪
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        @strongify(self);
        if (!self) return;
    
        if (!resizeImage) {
            NSLog(@"没有裁剪图片");
            return;
        }
        BOOL needSave = YES;
        if (resizeImage.size.width == self.image.size.width && resizeImage.size.height == self.image.size.height) {
            needSave = NO;
        }
        
        if (needSave) {
            if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCDidCrop:isCrop:)]) {
                [self.delegate ej_imageCropperVCDidCrop:resizeImage isCrop:YES];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCDidCrop:isCrop:)]) {
                [self.delegate ej_imageCropperVCDidCrop:_image isCrop:NO];
            }
        }
        
        BOOL needPop = YES;
        if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCAutoPopAfterCrop)]) {
            needPop = [self.delegate ej_imageCropperVCAutoPopAfterCrop];
        }
        if (needPop) {
            self.doneBtn.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

// 旋转
- (void)handleClickRotateButton:(UIButton *)sender {
    _rotateBtn.userInteractionEnabled = NO;
    _customImageView.hidden = YES;
    [self.imageresizerView rotation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _rotateBtn.userInteractionEnabled = YES;
        BOOL isNormal = _imageresizerView.verticalityMirror == _imageresizerView.horizontalMirror;
        
        CGFloat angle = (_imageresizerView.isClockwiseRotation ? 1.0 : -1.0) * (isNormal ? 1.0 : -1.0) * M_PI_2;
        CATransform3D fvTransform = CATransform3DRotate(_customImageView.layer.transform, -angle, 0, 0, 1);
        _customImageView.layer.transform = fvTransform;
        _customImageView.hidden = NO;
    });
}

@end
