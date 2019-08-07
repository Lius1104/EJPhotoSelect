//
//  LSAssetCollectionToolBar.m
//  LSPhotoSelect
//
//  Created by 刘爽 on 2018/9/6.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionToolBar.h"

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
        self.backgroundColor = [UIColor whiteColor];
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
        self.backgroundColor = [UIColor whiteColor];
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
    [_previewButton setTitleColor:kTintColor forState:UIControlStateNormal];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_previewButton addTarget:self action:@selector(handleClickPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_previewButton];
    
    _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_originalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _originalButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_normal"] forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_selected"] forState:UIControlStateSelected];
    _originalButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//    _originalButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    _originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_originalButton addTarget:self action:@selector(handleClickOriginalButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_originalButton];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"btn_normal"] forState:UIControlStateNormal];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"btn_disabled"] forState:UIControlStateDisabled];
    [_doneButton addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_doneButton];
    
//    _previewButton.backgroundColor = [UIColor redColor];
//    _originalButton.backgroundColor = [UIColor blueColor];
//    _doneButton.backgroundColor = [UIColor greenColor];
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
        make.width.mas_greaterThanOrEqualTo(56);
    }];
}

- (void)configSourceCount:(NSUInteger)count {
    if (_isShowCount) {
        NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:@"确定" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : UIColorHex(ffffff)}];
        if (count == 0) {
            [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [_doneButton setAttributedTitle:attStr forState:UIControlStateDisabled];
            _doneButton.enabled = NO;
        } else {
            _doneButton.enabled = YES;
            [_previewButton setTitle:[NSString stringWithFormat:@"预览(%d)", (int)count] forState:UIControlStateNormal];
            NSString * numString;
            if (_showPercentage == NO || _maxCount == 0) {
                numString = [NSString stringWithFormat:@"(%d)", (int)count];
            } else {
                numString = [NSString stringWithFormat:@"(%d/%d)", (int)count, (int)_maxCount];
            }
            if ([numString length] > 0) {
                NSAttributedString * numStr = [[NSAttributedString alloc] initWithString:numString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : UIColorHex(ffffff)}];
                [attStr appendAttributedString:numStr];
            }
            [_doneButton setAttributedTitle:attStr forState:UIControlStateNormal];
        }
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
