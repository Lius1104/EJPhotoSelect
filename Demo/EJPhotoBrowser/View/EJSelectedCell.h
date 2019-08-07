//
//  EJSelectedCell.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/5.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickDeleteBlock)(void);

@interface EJSelectedCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;

@property (nonatomic, copy) clickDeleteBlock block;

- (void)configClickDeleteBlock:(clickDeleteBlock)block;

@end

NS_ASSUME_NONNULL_END
