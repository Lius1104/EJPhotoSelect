//
//  LSAssetCollectionToolBar.m
//  LSPhotoSelect
//
//  Created by 刘爽 on 2018/9/6.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionToolBar.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "EJPhotoConfig.h"
#import "UIFont+EJAdd.h"

@interface LSAssetCollectionToolBar ()

@property (nonatomic, assign) BOOL isShowCount;

@property (nonatomic, assign) BOOL isShowOriginal;

@property (nonatomic, assign) NSUInteger maxCount;

@property (nonatomic, assign) BOOL showPercentage;

@property (nonatomic, strong) UIButton * previewButton;

@property (nonatomic, strong) UIButton * originalButton;

@property (nonatomic, strong) UIButton * doneButton;

@end

@implementation LSAssetCollectionToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return UIColorHex(1C1C1E);
                } else {
                    return UIColorHex(ffffff);
                }
            }];
        } else {
            // Fallback on earlier versions
            self.backgroundColor = UIColorHex(ffffff);
        }
        _isShowCount = YES;
        _isShowOriginal = YES;
        _showPercentage = NO;
        _maxCount = 0;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithShowCount:(BOOL)isShowCount isShowOriginal:(BOOL)isShowOriginal maxCount:(NSUInteger)maxCount showPercentage:(BOOL)showPercentage {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, 50)];
    if (self) {
//        self.backgroundColor = [UIColor whiteColor];
        
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return UIColorHex(1C1C1E);
                } else {
                    return UIColorHex(ffffff);
                }
            }];
        } else {
            // Fallback on earlier versions
            self.backgroundColor = UIColorHex(ffffff);
        }
        
        _isShowOriginal = isShowOriginal;
        _isShowCount = isShowCount;
        _maxCount = maxCount;
        if (_maxCount == NSUIntegerMax) {
            _showPercentage = NO;
        } else {
            _showPercentage = showPercentage;
        }
        [self setupSubviews];
    }
    return self;
}

+ (instancetype)ls_assetCollectionToolBarWithShowCount:(BOOL)isShowCount showOriginal:(BOOL)isShowOriginal maxCount:(NSUInteger)maxCount showPercentage:(BOOL)showPercentage {
    LSAssetCollectionToolBar * toolBar = [[LSAssetCollectionToolBar alloc] initWithShowCount:isShowCount isShowOriginal:isShowOriginal maxCount:maxCount showPercentage:showPercentage];
    return toolBar;
}

- (void)setupSubviews {
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIColor * color;
    if (@available(iOS 13.0, *)) {
        color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColorHex(ffffff);
            } else {
                return UIColorHex(333333);
            }
        }];
    } else {
        // Fallback on earlier versions
        color = UIColorHex(333333);
    }
    
    if ([EJPhotoConfig sharedPhotoConfig].majorTitleColor) {
        [_previewButton setTitleColor:[EJPhotoConfig sharedPhotoConfig].majorTitleColor forState:UIControlStateNormal];
    } else {
        [_previewButton setTitleColor:color forState:UIControlStateNormal];
    }
    
    _previewButton.titleLabel.font = [UIFont ej_pingFangSCRegularOfSize:14];
    _previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_previewButton addTarget:self action:@selector(handleClickPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.enabled = NO;
    [self addSubview:_previewButton];
    
    _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_originalButton setTitleColor:color forState:UIControlStateNormal];
    _originalButton.titleLabel.font = [UIFont ej_pingFangSCRegularOfSize:14];
    [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_normal"] forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_selected"] forState:UIControlStateSelected];
    _originalButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    _originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_originalButton addTarget:self action:@selector(handleClickOriginalButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_originalButton];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont ej_pingFangSCRegularOfSize:14];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"ejtools_btn_normal"] forState:UIControlStateNormal];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"ejtools_btn_disabled"] forState:UIControlStateDisabled];
    [_doneButton addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_doneButton];
    

    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [_doneButton setTitle:@"确定" forState:UIControlStateDisabled];
    
    [self setUpConstraints];
    
    if (!_isShowOriginal) {
        _originalButton.hidden = YES;
    }
}

- (void)setUpConstraints {
    [_previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(13);
        make.width.mas_equalTo(80);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(35);
    }];
    
    [_originalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.previewButton.mas_trailing).offset(20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(35);
    }];
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-10);
        make.centerY.equalTo(self);
//        make.width.mas_greaterThanOrEqualTo(56);
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(27);
    }];
}

- (void)configSourceCount:(NSUInteger)count {
    if (_isShowCount) {
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:@"确定" attributes:@{NSFontAttributeName : [UIFont ej_pingFangSCRegularOfSize:14], NSForegroundColorAttributeName : [UIColor whiteColor]}];
        if (count == 0) {
            [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [_doneButton setAttributedTitle:attStr forState:UIControlStateDisabled];
            _doneButton.enabled = NO;
            _previewButton.enabled = NO;
        } else {
            _doneButton.enabled = YES;
            _previewButton.enabled = YES;
            [_previewButton setTitle:[NSString stringWithFormat:@"预览(%d)", (int)count] forState:UIControlStateNormal];
            NSString * numString;
            if (_showPercentage == NO || _maxCount == 0) {
                numString = [NSString stringWithFormat:@"(%d)", (int)count];
                NSAttributedString * numStr = [[NSAttributedString alloc] initWithString:numString attributes:@{NSFontAttributeName : [UIFont ej_pingFangSCRegularOfSize:14], NSForegroundColorAttributeName : [UIColor whiteColor]}];
                [attStr appendAttributedString:numStr];
            } else {
                numString = [NSString stringWithFormat:@"(%d/%d)", (int)count, (int)_maxCount];
                NSAttributedString * numStr = [[NSAttributedString alloc] initWithString:numString attributes:@{NSFontAttributeName : [UIFont ej_pingFangSCRegularOfSize:14], NSForegroundColorAttributeName : [UIColor whiteColor]}];
                [attStr appendAttributedString:numStr];
            }
            [_doneButton setAttributedTitle:attStr forState:UIControlStateNormal];
        }
        
        CGFloat doneWidth = ceil([attStr boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width);
        doneWidth = (doneWidth + 12) > 56 ? doneWidth + 12 : 56;
        [_doneButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(doneWidth);
        }];
    }
}

#pragma mark - action
- (void)handleClickPreviewButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickPreviewButton)]) {
        [self.delegate ls_assetCollectionToolBarDidClickPreviewButton];
    }
}

- (void)handleClickOriginalButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickOriginalButton:)]) {
        [self.delegate ls_assetCollectionToolBarDidClickOriginalButton:sender];
    }
}

- (void)handleClickDoneButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickDoneButton)]) {
        [self.delegate ls_assetCollectionToolBarDidClickDoneButton];
    }
}

@end
