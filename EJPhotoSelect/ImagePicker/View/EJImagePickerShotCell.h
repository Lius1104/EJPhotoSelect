//
//  EJImagePickerShotCell.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EJImagePickerShotCell;

NS_ASSUME_NONNULL_BEGIN

@protocol EJImagePickerShotCellDelegate <NSObject>

- (void)ej_imagePickerShotCellDidClick:(EJImagePickerShotCell *)cell;

@end

@interface EJImagePickerShotCell : UICollectionViewCell

@property (nonatomic, weak) id <EJImagePickerShotCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
