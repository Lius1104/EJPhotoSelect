//
//  LSEditFrameView.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/17.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSEditFrameViewDelegate <NSObject>

- (void)ls_editFrameValidRectChanged;

- (void)ls_editFrameValidRectEndChange;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LSEditFrameView : UIView

- (instancetype)initWithItemSize:(CGSize)itemSize initRect:(CGRect)initRect;


/**
  最大的框
 */
@property (nonatomic, assign) CGRect initRect;

/**
 当前的框
 */
@property (nonatomic, assign) CGRect validRect;

@property (nonatomic, weak) id <LSEditFrameViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
