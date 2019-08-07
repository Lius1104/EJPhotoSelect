//
//  EJImageCropperVC.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/6/4.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImageCropperVC.h"
#import <JPImageresizerView.h>
#import <UINavigationController+FDFullscreenPopGesture.h>

@interface EJImageCropperVC ()

@property (nonatomic, strong) UIImage * image;

@property (nonatomic, strong) JPImageresizerView * imageresizerView;

@property (nonatomic, strong) UIButton * cancelBtn;

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
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(handleClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneBtn setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneBtn];
    
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(25);
        make.size.mas_equalTo(CGSizeMake(50, 30));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-40);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-40);
        }
    }];
    [_doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-25);
        make.size.equalTo(_cancelBtn);
        make.bottom.equalTo(_cancelBtn.mas_bottom);
    }];
    
//    __weak typeof(self) wSelf = self;
    @weakify(self);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(50, 0, (40 + 30 + 30 + 10), 0);
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:_image make:^(JPImageresizerConfigure *configure) {
        configure.jp_contentInsets(contentInsets);
    }];
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
//        @strongify(self);
//        __strong typeof(wSelf) sSelf = wSelf;
//        if (!self) return;
        // 当不需要重置设置按钮不可点
//        sSelf.recoveryBtn.enabled = isCanRecovery;
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @strongify(self);
//        __strong typeof(wSelf) sSelf = wSelf;
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        self.doneBtn.enabled = enabled;
    }];
    imageresizerView.resizeWHScale = _cropScale;
    [self.view insertSubview:imageresizerView atIndex:0];
    self.imageresizerView = imageresizerView;
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
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
    // 默认以imageView的宽度为参照宽度进行裁剪
//    [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
//        @strongify(self);
//        if (!self) return;
//
//        if (!resizeImage) {
//            NSLog(@"没有裁剪图片");
//            return;
//        }
//        if ([self.delegate respondsToSelector:@selector(ej_imageCropperVCDidCrop:)]) {
//            [self.delegate ej_imageCropperVCDidCrop:resizeImage];
//        }
//
//        self.doneBtn.enabled = YES;
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
}

@end
