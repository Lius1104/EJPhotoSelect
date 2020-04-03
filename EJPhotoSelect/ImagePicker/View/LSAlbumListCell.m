//
//  LSAlbumListCell.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAlbumListCell.h"
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "UIFont+EJAdd.h"

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
        
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ej_pingFangSCRegularOfSize:14];
        if (@available(iOS 13.0, *)) {
            _titleLabel.textColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return UIColorHex(ffffff);
                } else {
                    return UIColorHex(333333);
                }
            }];
        } else {
            // Fallback on earlier versions
            _titleLabel.textColor = UIColorHex(333333);
        }
        
        
        [self.contentView addSubview:_titleLabel];
        
        _intoImageView = [[UIImageView alloc] init];
        _intoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_intoImageView];
        
        _bottomLine = [[UIView alloc] init];
        if (@available(iOS 13.0, *)) {
            _bottomLine.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return UIColorHex(444444);
                } else {
                    return UIColorHex(E3E3E3);
                }
            }];
        } else {
            // Fallback on earlier versions
            _bottomLine.backgroundColor = UIColorHex(E3E3E3);
        }
        
        [self.contentView addSubview:_bottomLine];
        
        [self configConstrains];
    }
    return self;
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(14);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerY.equalTo(self);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(12);
        make.top.bottom.equalTo(self);
    }];
    
    [_intoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.coverImageView.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-14);
        make.size.mas_equalTo(CGSizeMake(7, 13));
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self).offset(14);
        make.right.equalTo(self).offset(-14);
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
