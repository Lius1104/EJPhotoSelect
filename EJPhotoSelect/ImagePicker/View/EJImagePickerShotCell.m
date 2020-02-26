//
//  EJImagePickerShotCell.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImagePickerShotCell.h"
#import <Masonry/Masonry.h>

@interface EJImagePickerShotCell ()

@property (nonatomic, strong) UIButton * shotButton;


@end

@implementation EJImagePickerShotCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _shotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shotButton setImage:[UIImage imageNamed:@"ejtools_camera"] forState:UIControlStateNormal];
        [_shotButton addTarget:self action:@selector(handleClickShotButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shotButton];
        [_shotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)handleClickShotButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ej_imagePickerShotCellDidClick:)]) { 
        [self.delegate ej_imagePickerShotCellDidClick:self];
    }
}

@end
