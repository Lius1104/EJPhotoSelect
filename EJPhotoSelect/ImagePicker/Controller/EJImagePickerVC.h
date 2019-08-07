//
//  EJImagePickerVC.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJViewController.h"
#import "ImagePickerEnums.h"

@protocol EJImagePickerDelegate <NSObject>

- (void)ej_imagePickerDidSelected:(NSMutableArray *)source;

@end

//NS_ASSUME_NONNULL_BEGIN

@interface EJImagePickerVC : EJViewController

@property (nonatomic, weak) id <EJImagePickerDelegate> delegate;

/**
 裁剪比例。默认为0，用户可自由调整比例
 */
@property (nonatomic, assign) CGFloat cropScale;

/**
 视频的最大时长，默认为180s
 */
@property (nonatomic, assign) NSTimeInterval maxVideoDuration;

/**
 单选状态下，点击图片/视频 是否直接跳转到编辑页面（仅在单选状态下有效）：YES，跳转到编辑页面；NO，跳转到 大图浏览页面。默认为YES
 */
@property (nonatomic, assign) BOOL directEdit;

/**
 预览页面 取消选中后是否直接将t其从预览页面移除，默认为 NO
 */
@property (nonatomic, assign) BOOL previewDelete;

/**
 浏览页面单选确定 是否提示裁剪。仅在 maxSelecteCount == 1 && cropScale != 0 && directEdit == NO 时 forcedCrop == YES才有效；默认为YES
 */
@property (nonatomic, assign) BOOL forcedCrop;

/**
 配置 UI

 @param inserts <#inserts description#>
 @param cellSpace <#cellSpace description#>
 @param num <#num description#>
 */
- (void)configSectionInserts:(UIEdgeInsets)inserts cellSpace:(NSUInteger)cellSpace numOfLineCells:(NSUInteger)num;

- (instancetype)initWithSourceType:(E_SourceType)sourceType MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray <PHAsset *>*)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop;

@end

//NS_ASSUME_NONNULL_END
