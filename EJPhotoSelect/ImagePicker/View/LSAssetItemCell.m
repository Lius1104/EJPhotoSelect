//
//  LSAssetItemCell.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetItemCell.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface LSAssetItemCell ()

@property (nonatomic, strong) UIView * noEditorView;

@property (nonatomic, strong) UIButton * normalButton;

@property (nonatomic, strong) UITapGestureRecognizer * tapMain;

@property (nonatomic, copy) LSSelectSourceBlock block;


@end

@implementation LSAssetItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hideNoEditorLayer = YES;
        
        _sourceSelected = NO;
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        
//        _livePhotoIcon = [[UIImageView alloc] init];
//        _livePhotoIcon.contentMode = UIViewContentModeScaleAspectFill;
//        [self addSubview:_livePhotoIcon];
        
        _normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_normalButton setImage:[UIImage imageNamed:@"ejtools_imagePicker_normal"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"ejtools_imagePicker_selected"] forState:UIControlStateSelected];
        
        _normalButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _normalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        [_normalButton addTarget:self action:@selector(handleClickNormalButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_normalButton];
        
        _videoLabel = [[UILabel alloc] init];
        _videoLabel.font = [UIFont systemFontOfSize:13];
        _videoLabel.textColor = UIColorHex(ffffff);
        _videoLabel.hidden = YES;
        [self addSubview:_videoLabel];
        
        _editImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ejtools_imageEdit"]];
        [self addSubview:_editImage];
        
        _noEditorView = [[UIView alloc] init];
        _noEditorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.65];
        _noEditorView.hidden = self.isHideNoEditor;
        [self addSubview:_noEditorView];
        
        [self configConstrains];
    }
    return self;
}

- (void)setHideNoEditorLayer:(BOOL)hideNoEditorLayer {
    if (self.isHideNoEditor != hideNoEditorLayer) {
        _hideNoEditorLayer = hideNoEditorLayer;
        _noEditorView.hidden = self.isHideNoEditor;
        _normalButton.hidden = !self.isHideNoEditor;
    }
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
//    [_livePhotoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(28, 28));
//    }];
    
    [_normalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
        make.height.equalTo(_normalButton.mas_width);
    }];
    
    [_videoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
        make.height.mas_equalTo(ceil(_videoLabel.font.lineHeight));
    }];
    
    [_editImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [_noEditorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setSourceSelected:(BOOL)sourceSelected {
    _sourceSelected = sourceSelected;
    _normalButton.selected = _sourceSelected;
}

- (void)setIsSelectable:(BOOL)isSelectable {
    _isSelectable = isSelectable;
    if (isSelectable) {
        _normalButton.hidden = NO;
    } else {
        _normalButton.hidden = YES;
    }
}

- (void)setUpSelectSourceBlock:(LSSelectSourceBlock)block {
    if (block) {
        self.block = [block copy];
    }
}

- (void)handleClickNormalButton:(UIButton *)sender {
    if (self.block) {
        self.block(self.localIdentifier);
    }
}

@end
