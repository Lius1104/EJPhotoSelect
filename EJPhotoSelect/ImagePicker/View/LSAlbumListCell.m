//
//  LSAlbumListCell.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAlbumListCell.h"

@interface LSAlbumListCell ()


@property (nonatomic, strong) UIView * bottomLine;

@end

@implementation LSAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = UIColorHex(333333);
        [self.contentView addSubview:_titleLabel];
        
        _intoImageView = [[UIImageView alloc] init];
        _intoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_intoImageView];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = UIColorHex(dadada);
        [self.contentView addSubview:_bottomLine];
        
        [self configConstrains];
    }
    return self;
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.centerY.equalTo(self.contentView);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(16);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    [_intoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.coverImageView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-13);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(19);
        make.right.equalTo(self.contentView).offset(-11);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setUpCoverImage:(UIImage *)coverImage {
    if (coverImage) {
        _coverImageView.image = coverImage;
    } else {
        _coverImageView.image = [UIImage imageNamed:@"default_cover"];
    }
}

@end
