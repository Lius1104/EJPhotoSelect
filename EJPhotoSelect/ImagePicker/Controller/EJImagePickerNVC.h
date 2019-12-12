//
//  EJImagePickerNVC.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ImagePickerEnums.h"

//NS_ASSUME_NONNULL_BEGIN

@class EJImagePickerNVC;

@protocol EJImagePickerVCDelegate <NSObject>

@optional
- (void)ej_imagePickerVC:(EJImagePickerNVC *)imagePicker didSelectedSource:(NSMutableArray *)source;

- (void)ej_imagePickerVC:(EJImagePickerNVC *)imagePicker didCroppedImage:(UIImage *)image;

@end


@interface EJImagePickerNVC : UINavigationController

@property (nonatomic, weak) id <EJImagePickerVCDelegate> pickerDelegate;
/// 自定义 title
@property (nonatomic, copy) NSString * customTitle;

/**
 最大选中数量
 */
@property (nonatomic, assign) NSUInteger maxCount;

/**
 本地资源类型
 */
@property (nonatomic, assign) E_SourceType sourceType;

@property (nonatomic, strong) NSMutableArray <PHAsset *>* selectedSource;

@property (nonatomic, assign) BOOL showShot;

@property (nonatomic, assign) BOOL allowCrop;

@property (nonatomic, assign) CGFloat cropScale;

@property (nonatomic, assign) NSUInteger maxVideoDuration;

/**
 单选状态下，点击图片/视频 是否直接跳转到编辑页面（仅在单选状态下有效）：YES，跳转到编辑页面；NO，跳转到 大图浏览页面。
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

///  拍摄完成之后 是否进入到 浏览全部本地资源页面, 默认为 YES
@property (nonatomic, assign) BOOL browserAfterShot;

/// 裁剪之后 是否 自动返回，默认为 YES
@property (nonatomic, assign) BOOL autoPopAfterCrop;

/// 自定义裁剪边框
@property (nonatomic, strong) UIImage * customCropBorder;
@property (nonatomic, strong) UIImage * customLayerImage;
@property (nonatomic, copy) NSString * cropWarningTitle;

/**
 配置 UI

 @param inserts default is UIEdgesInsertsZero.
 @param cellSpace default is 2.
 @param num default is 4, [3 - 5]; only for iphone.
 */
- (void)configSectionInserts:(UIEdgeInsets)inserts cellSpace:(NSUInteger)cellSpace numOfLineCells:(NSUInteger)num;

/**
 <#Description#>

 @param sourceType <#sourceType description#>
 @param maxCount <#maxCount description#>
 @param selectedSource <#selectedSource description#>
 @param increaseOrder <#increaseOrder description#>
 @param showShot <#showShot description#>
 @param allowCrop <#allowCrop description#>
 @return <#return value description#>
 */
- (instancetype)initWithSourceType:(E_SourceType)sourceType MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray <PHAsset *>*)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop;

@end

//NS_ASSUME_NONNULL_END
