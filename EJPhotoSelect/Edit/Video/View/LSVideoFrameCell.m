//
//  LSVideoFrameCell.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSVideoFrameCell.h"
#import <Masonry/Masonry.h>

@implementation LSVideoFrameCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
