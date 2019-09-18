//
//  LSAssetCollectionToolBar.h
//  LSPhotoSelect
//
//  Created by 刘爽 on 2018/9/6.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSAssetCollectionToolBarDelegate <NSObject>

- (void)ls_assetCollectionToolBarDidClickPreviewButton;

- (void)ls_assetCollectionToolBarDidClickOriginalButton:(UIButton *)originalButton;

- (void)ls_assetCollectionToolBarDidClickDoneButton;

@end

@interface LSAssetCollectionToolBar : UIView

@property (nonatomic, weak) id <LSAssetCollectionToolBarDelegate> delegate;

@property (nonatomic, assign, readonly) NSUInteger currentCount;


- (instancetype)initWithShowCount:(BOOL)isShowCount isShowOriginal:(BOOL)isShowOriginal maxCount:(NSUInteger)maxCount showPercentage:(BOOL)showPercentage;

+ (instancetype)ls_assetCollectionToolBarWithShowCount:(BOOL)isShowCount showOriginal:(BOOL)isShowOriginal maxCount:(NSUInteger)maxCount showPercentage:(BOOL)showPercentage;

- (void)configSourceCount:(NSUInteger)count;

@end
