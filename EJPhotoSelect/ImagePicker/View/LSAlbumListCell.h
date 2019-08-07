//
//  LSAlbumListCell.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAlbumListCell : UITableViewCell

@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) UILabel * titleLabel;
//@property (nonatomic, strong) UILabel * numLabel;

@property (nonatomic, strong) UIImageView * intoImageView;

- (void)setUpCoverImage:(UIImage *)coverImage;

@end
