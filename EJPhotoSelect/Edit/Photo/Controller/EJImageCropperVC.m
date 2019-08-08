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

@interface EJImageCropperVC ()

@property (nonatomic, strong) UIImage * image;

@property (nonatomic, strong) JPImageresizerView * imageresizerView;

@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIButton * cancelBtn;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * doneBtn;

@end

@implementation EJImageCropperVC

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _cropScale = 0;
        _image = image;
    }
    return self;
}

- (void)viewDidLoad {
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorHex(ffffff);
    
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
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = UIColorHex(4F4F4F);
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.text = @"剪裁";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:_titleLabel];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setImage:[UIImage imageNamed:@"ejtools_crop_done"] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneBtn setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.centerY.equalTo(_bottomView);
    }];
    [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.equalTo(_cancelBtn);
        make.bottom.equalTo(_cancelBtn.mas_bottom);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_cancelBtn.mas_right);
        make.right.equalTo(_doneBtn.mas_left);
        make.height.equalTo(_bottomView.mas_height);
        make.top.equalTo(_bottomView.mas_top);
    }];
    
//    __weak typeof(self) wSelf = self;
    @weakify(self);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 0, (56 + 24), 0);
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:_image make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(contentInsets);
    }];
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @strongify(self);
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        self.doneBtn.enabled = enabled;
    }];
    imageresizerView.resizeWHScale = _cropScale;
    imageresizerView.frameType = JPClassicFrameType;
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    
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
        if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCDidCrop:)]) {
            [self.delegate ej_imageCropperVCDidCrop:resizeImage];
        }
        
        self.doneBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
