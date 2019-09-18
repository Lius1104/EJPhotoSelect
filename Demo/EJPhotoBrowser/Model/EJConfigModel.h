//
//  EJConfigModel.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/5.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EJConfigModel : NSObject

#pragma mark - 功能
@property (nonatomic, assign) BOOL allowShot;

@property (nonatomic, assign) BOOL increaseOrder;

@property (nonatomic, assign) NSUInteger sourceType;

@property (nonatomic, assign) BOOL singleSelect;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGFloat cropScale;
@property (nonatomic, assign) NSUInteger videoDefaultDuration;

@property (nonatomic, assign) NSUInteger maxSelectCount;

/**
 单选状态下，点击图片/视频 是否直接跳转到编辑页面（仅在单选且允许编辑状态下有效）：YES，跳转到编辑页面；NO，跳转到 大图浏览页面。
 */
@property (nonatomic, assign) BOOL directEdit;

/**
  预览页面 取消选中后是否直接将t其从预览页面移除，默认为 YES
 */
@property (nonatomic, assign) BOOL previewDelete;

/**
  浏览页面单选确定 是否提示裁剪。仅在 maxSelecteCount == 1 && cropScale != 0 && directEdit == NO 时 forcedCrop == YES才有效；默认为YES
 */
@property (nonatomic, assign) BOOL forcedCrop;

@property (nonatomic, assign) BOOL browserAfterShot;


#pragma mark - UI
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
@property (nonatomic, assign) NSUInteger cellSpace;
@property (nonatomic, assign) NSUInteger numOfLineCells;


@end

NS_ASSUME_NONNULL_END
