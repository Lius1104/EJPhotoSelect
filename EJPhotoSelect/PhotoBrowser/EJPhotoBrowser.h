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
//#import "EJCaptionView.h"

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
//- (EJCaptionView *)photoBrowser:(EJPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(EJPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
//- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;

/**
 当前资源是否选中

 @param photoBrowser <#photoBrowser description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;

/**
 当前资源选中状态改变

 @param photoBrowser <#photoBrowser description#>
 @param index <#index description#>
 @param selected <#selected description#>
 */
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;

/**
 是否可以继续选择

 @param photoBrowser <#photoBrowser description#>
 @return <#return value description#>
 */
- (BOOL)photoBrowserCanPhotoSelectedAtIndex:(EJPhotoBrowser *)photoBrowser;


/**
 编辑过图片/视频后调用该方法

 @param photoBrowser 图片浏览器
 @param index 当前被编辑的索引
 @param asset 编辑后的新资源
 */
//- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didEditSourceAtIndex:(NSUInteger)index currentAsset:(PHAsset *)asset;

- (void)photoBrowserDidFinishModalPresentation:(EJPhotoBrowser *)photoBrowser;

/**
 点击返回

 @param photoBrowser <#photoBrowser description#>
 */
- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser;

/**
 <#Description#>

 @param photoBrowser <#photoBrowser description#>
 */
- (void)photoBrowserDidFinish:(EJPhotoBrowser *)photoBrowser;

/**
 已经选中的数量

 @param photoBrowser <#photoBrowser description#>
 @return <#return value description#>
 */
- (NSUInteger)photoBrowserSelectedPhotoCount:(EJPhotoBrowser *)photoBrowser;

/**
 总共需要选中的数量

 @param photoBrowser <#photoBrowser description#>
 @return <#return value description#>
 */
- (NSUInteger)photoBrowserMaxSelectePhotoCount:(EJPhotoBrowser *)photoBrowser;

/**
 当前图片允许的裁剪比例

 @param photoBrowser <#photoBrowser description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (CGFloat)photoBrowser:(EJPhotoBrowser *)photoBrowser crapScaleAtIndex:(NSUInteger)index;

/**
 裁剪

 @param photoBrowser <#photoBrowser description#>
 @param index <#index description#>
 */
- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index assetId:(NSString *)assetId;

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
