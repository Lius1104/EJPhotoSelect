//
//  LSAssetItemCell.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class LSAssetItemCell;

typedef void(^LSSelectSourceBlock)(NSString * clickLocalIdentifier);

@interface LSAssetItemCell : UICollectionViewCell

@property (nonatomic, copy) NSString * localIdentifier;

@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) UIImageView * livePhotoIcon;

//@property (nonatomic, strong) UIImageView * playImage;
@property (nonatomic, strong) UILabel * videoLabel;

@property (nonatomic, strong) UIImage * normalImage;

@property (nonatomic, strong) UIImage * selectedImage;

@property (nonatomic, assign) BOOL sourceSelected;


@property (nonatomic, assign, getter=canSelect) BOOL isSelectable;

//- (void)showSelecteButton:(BOOL)isShow;

- (void)setUpSelectSourceBlock:(LSSelectSourceBlock)block;

@end
