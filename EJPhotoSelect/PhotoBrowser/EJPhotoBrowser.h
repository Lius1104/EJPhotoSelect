//
//  EJPhotoBrowser.h
//  EJPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EJPhoto.h"
#import "EJPhotoProtocol.h"
#import "ImagePickerEnums.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define EJLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define EJLog(x, ...)
#endif

@class EJPhotoBrowser;

@protocol EJPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(EJPhotoBrowser *)photoBrowser;
- (id <EJPhoto>)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <EJPhoto>)photoBrowser:(EJPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;

- (void)photoBrowserDidFinishModalPresentation:(EJPhotoBrowser *)photoBrowser;

/**
 点击返回

 @param photoBrowser EJPhotoBrowser
 */
- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser;

/**
 点击完成

 @param photoBrowser EJPhotoBrowser
 */
- (void)photoBrowserDidFinish:(EJPhotoBrowser *)photoBrowser;

#pragma mark - select
/**
 已经选中的数量

 @param photoBrowser EJPhotoBrowser
 @return NSUInteger
 */
- (NSUInteger)photoBrowserSelectedPhotoCount:(EJPhotoBrowser *)photoBrowser;

/**
 总共需要选中的数量

 @param photoBrowser EJPhotoBrowser
 @return NSUInteger
 */
- (NSUInteger)photoBrowserMaxSelectePhotoCount:(EJPhotoBrowser *)photoBrowser;

/**
 当前资源是否选中
 
 @param photoBrowser EJPhotoBrowser
 @param index NSUInteger
 @return BOOL
 */
- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;

/**
 当前资源选中状态改变
 
 @param photoBrowser EJPhotoBrowser
 @param index NSUInteger
 @param selected BOOL
 */
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;

/**
 是否可以继续选择
 
 @param photoBrowser EJPhotoBrowser
 @return BOOL
 */
- (BOOL)photoBrowserCanPhotoSelectedAtIndex:(EJPhotoBrowser *)photoBrowser;

#pragma mark - edit
/**
 当前图片允许的裁剪比例

 @param photoBrowser EJPhotoBrowser
 @param index NSUInteger
 @return CGFloat
 */
- (CGFloat)photoBrowser:(EJPhotoBrowser *)photoBrowser crapScaleAtIndex:(NSUInteger)index;

/// 裁剪结果
/// @param photoBrowser EJPhotoBrowser
/// @param index 索引
/// @param localPath 沙盒路径 相对路径
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index localPath:(NSString *)localPath;

/// 当前资源是否编辑过
/// @param photoBrowser 图片浏览器
/// @param index 当前索引
- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoEditedAtIndex:(NSUInteger)index;

/// 当前资源还原
/// @param photoBrowser 图片浏览器
/// @param index 当前索引
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoReductionAtIndex:(NSUInteger)index;

#pragma mark - single select
/**
 是否只能选择一种类型

 @param photoBrowser EJPhotoBrowser
 @param singleSelect BOOL
 */
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser canSingleSelect:(BOOL)singleSelect;

/**
 单选类型

 @param photoBrowser EJPhotoBrowser
 @param selectedType E_SourceType
 */
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser selectedType:(E_SourceType)selectedType;

@end

@interface EJPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet id<EJPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;

@property (nonatomic, assign) BOOL showSelectButton;
@property (nonatomic, assign) BOOL showCropButton;
@property (nonatomic, assign) BOOL alwaysShowControl;

@property (nonatomic) BOOL autoPlayOnAppear;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;


@property (nonatomic, strong) NSString *customImageSelectedIconName;
@property (nonatomic, strong) NSString *customImageSelectedSmallIconName;

/**
视频的最长时间
 */
@property (nonatomic, assign) NSTimeInterval maxVideoDuration;


/**
 是否是预览
 */
@property (nonatomic, assign) BOOL isPreview;

/**
 是否强制裁剪
 */
@property (nonatomic, assign) BOOL forcedCrop;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithDelegate:(id <EJPhotoBrowserDelegate>)delegate;

// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
