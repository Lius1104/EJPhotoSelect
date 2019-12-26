//
//  EJImagePickerVC.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImagePickerVC.h"
#import "EJAlbumPickerVC.h"
#import "LSAssetItemCell.h"
#import "LSAssetCollectionToolBar.h"
#import "ImagePickerEnums.h"
#import <PhotosUI/PhotosUI.h>
#import <EJTools/UIViewController+EJAdd.h>
#import <Masonry/Masonry.h>
#import <LSToolsKit/LSToolsKit.h>
#import <EJTools/EJTools.h>
#import <YYKit/YYKit.h>
#import "UIViewController+LSAuthorization.h"
#import "EJImagePickerShotCell.h"
#import "EJCameraShotVC.h"

#import "EJPhotoBrowser.h"
#import "EJImageCropperVC.h"
#import "NSString+EJShot.h"

#import "LSInterceptVideo.h"

#import "EJPhotoConfig.h"

@interface EJImagePickerVC ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver, LSAssetCollectionToolBarDelegate, EJImagePickerShotCellDelegate, EJCameraShotVCDelegate, EJPhotoBrowserDelegate, EJImageCropperDelegate, LSInterceptVideoDelegate> {
    CGRect previousPreheatRect;
    BOOL _isLocalSelected;
}

@property (nonatomic, strong) PHAssetCollection * assetCollection;

@property (nonatomic, strong) PHCachingImageManager * manager;

@property (nonatomic, strong) PHImageRequestOptions * options;

@property (nonatomic, assign) BOOL isNeedScroll;

@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, assign, readonly) NSInteger lineItemCount;
@property (nonatomic, assign, readonly) UIEdgeInsets sectionInset;
@property (nonatomic, assign, readonly) CGFloat itemSpace;
@property (nonatomic, assign, readonly) CGSize itemSize;
@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, strong) LSAssetCollectionToolBar * toolBar;

@property (nonatomic, strong) PHFetchResult <PHAsset *>* fetchResult;

@property (nonatomic, assign) BOOL showShot;

@property (nonatomic, assign) BOOL allowCrop;

@property (nonatomic, assign) E_SourceType sourceType;

@property (nonatomic, assign, readonly) LSSortOrder sortOrder;

@property (nonatomic, assign) NSUInteger maxSelectedCount;

@property (nonatomic, strong) NSMutableArray <PHAsset *>* selectedSource;

@property (nonatomic, strong) EJAlbumPickerVC * albumVC;

@property (nonatomic, strong) NSMutableArray * browserSource;

@end

@implementation EJImagePickerVC

- (instancetype)initWithSourceType:(E_SourceType)sourceType MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray<PHAsset *> *)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop {
    self = [super init];
    if (self) {
        _cropScale = 0;
        self.sourceType = sourceType;
        self.showShot = showShot;
        self.allowCrop = allowCrop;
        self.maxSelectedCount = maxCount;
        self.directEdit = YES;
        self.maxVideoDuration = 180;
        self.previewDelete = YES;
        self.forcedCrop = YES;
        self.autoPopAfterCrop = YES;
        
        _isNeedScroll = YES;
        _lineItemCount = 4;
        _sectionInset = UIEdgeInsetsMake(0, 1, 0, 1);
        _itemSpace = 1;
        
        _browserAfterShot = YES;
        
        CGFloat availableWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - _sectionInset.left - _sectionInset.right - (_itemSpace * (_lineItemCount - 1));
        CGFloat width = availableWidth / _lineItemCount;
        _itemSize = CGSizeMake(width, width);
        
        _imageSize = CGSizeMake(width * 2, width * 2);
        
        _sortOrder = increaseOrder ? LSSortOrderAscending : LSSortOrderDescending;
        
        _selectedSource = selectedSource;
        
        _manager = [[PHCachingImageManager alloc] init];
        _options = [[PHImageRequestOptions alloc] init];
        _options.networkAccessAllowed = YES;
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return self;
}

- (void)dealloc {
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    NSLog(@"EJImagePickerVC dealloc.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorHex(ffffff);
    if ([_customTitle length] > 0) {
        self.title = _customTitle;
    } else {
        self.title = @"选择照片视频";
    }
    
    if ([EJPhotoConfig sharedPhotoConfig].barTintColor) {
       self.navigationController.navigationBar.barTintColor = [EJPhotoConfig sharedPhotoConfig].barTintColor;
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    }
    
    if ([EJPhotoConfig sharedPhotoConfig].tintColor) {
        self.navigationController.navigationBar.tintColor = [EJPhotoConfig sharedPhotoConfig].tintColor;
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [EJPhotoConfig sharedPhotoConfig].tintColor};
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    }
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ejtools_imagePicker_back"] style:UIBarButtonItemStyleDone target:self action:@selector(handleClickLeftItem)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        if (self.maxSelectedCount == 1) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        } else {
            make.bottom.equalTo(self.toolBar.mas_top);
        }
    }];
    if (_maxSelectedCount != 1) {
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.collectionView.mas_bottom);
            make.height.mas_equalTo(self.toolBar.bounds.size.height);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
        _toolBar.hidden = NO;
        [_toolBar configSourceCount:self.selectedSource.count];
    } else {
        self.toolBar.hidden = YES;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self judgeAppPhotoLibraryUsageAuth:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusRestricted: {
                NSLog(@"访问限制.");
            }
                break;
            case PHAuthorizationStatusDenied: {
                NSLog(@"访问被拒.");
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIButton * albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    albumBtn.frame = CGRectMake(0, 0, 50, 34);
                    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
                    albumBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                    if ([EJPhotoConfig sharedPhotoConfig].tintColor) {
                        [albumBtn setTitleColor:[EJPhotoConfig sharedPhotoConfig].tintColor forState:UIControlStateNormal];
                    } else {
                        [albumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    }

                    [albumBtn addTarget:self action:@selector(handleClickRightItem) forControlEvents:UIControlEventTouchUpInside];
                    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:albumBtn];
                    self.navigationItem.rightBarButtonItem = rightItem;
                    [self getAllAssets];
                    [_collectionView reloadData];
                    if (_sortOrder == LSSortOrderAscending) {
                        if (_fetchResult.count > 0) {
                            NSInteger count = _fetchResult.count;
                            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
                            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                        }
                    }
                });
            }
                break;
            case PHAuthorizationStatusNotDetermined: {
                NSLog(@"未决定.");
            }
                break;
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isNeedScroll == YES) {
        if (_sortOrder == LSSortOrderAscending) {
            if (_fetchResult.count > 0) {
                [_collectionView reloadData];
                NSInteger count = _fetchResult.count;
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
                [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }
        }
        self.isNeedScroll = NO;
    }
}

- (void)configSectionInserts:(UIEdgeInsets)inserts cellSpace:(NSUInteger)cellSpace numOfLineCells:(NSUInteger)num {
    _sectionInset = inserts;
    _itemSpace = cellSpace;
    _lineItemCount = num;
    
    CGFloat availableWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - _sectionInset.left - _sectionInset.right - (_itemSpace * (_lineItemCount - 1));
    CGFloat width = availableWidth / _lineItemCount;
    _itemSize = CGSizeMake(width, width);
    
    _imageSize = CGSizeMake(width * 2, width * 2);
}

- (void)getAllAssets {
    if (_assetCollection == nil) {
        PHFetchResult<PHAssetCollection *> * smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection * item in smartAlbum) {
            if (item.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                _assetCollection = item;
                break;
            }
        }
    }
    if (_assetCollection == nil)
        return;
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    switch (_sourceType) {
        case E_SourceType_Image: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
            break;
        case E_SourceType_Video: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
            break;
        case E_SourceType_All: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
            break;
    }
    BOOL isAscending = _sortOrder == LSSortOrderAscending ? YES : NO;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscending];
    options.sortDescriptors = @[sort];
    _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:options];
    if (_maxSelectedCount != 1) {
        if ([_customTitle length] > 0) {
            self.title = _customTitle;
        } else {
            NSString * title = [_assetCollection.localizedTitle length] > 0 ? _assetCollection.localizedTitle : @"";
            self.title = [NSString stringWithFormat:@"%@(%d)", title, (int)_fetchResult.count];
        }
    }
}

- (void)resetCachedAssets {
    [_manager stopCachingImagesForAllAssets];
    previousPreheatRect = CGRectZero;
}

- (void)updateAssetsCache {
    // self.view.window == nil 判断当前view是否显示在屏幕上
    if (!self.isViewLoaded || self.view.window == nil) {
        return;
    }
    
    // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
    CGRect visibleRect = CGRectMake(0.f, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
    
    // 只有当可见区域与最后一个预热区域显著不同时才更新
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect));
    if (delta > self.view.bounds.size.height / 3.f) {
        // 计算开始缓存和停止缓存的区域
        [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            [self imageManagerStopCachingImagesWithRect:removedRect];
        } addedHandler:^(CGRect addedRect) {
            [self imageManagerStartCachingImagesWithRect:addedRect];
        }];
        previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        //添加 向下滑动(往下翻看新的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        //添加 向上滑动(往上翻看之前的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        //当 oldRect 与 newRect 没有相交区域时
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (void)imageManagerStartCachingImagesWithRect:(CGRect)rect {
    NSMutableArray<PHAsset *> *addAssets = [self indexPathsForElementsWithRect:rect];
    [_manager startCachingImagesForAssets:addAssets targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:_options];
}

- (void)imageManagerStopCachingImagesWithRect:(CGRect)rect {
    NSMutableArray<PHAsset *> *removeAssets = [self indexPathsForElementsWithRect:rect];
    [_manager stopCachingImagesForAssets:removeAssets targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:_options];
}

- (NSMutableArray<PHAsset *> *)indexPathsForElementsWithRect:(CGRect)rect {
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributes = [layout layoutAttributesForElementsInRect:rect];
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (__kindof UICollectionViewLayoutAttributes *layoutAttr in layoutAttributes) {
        NSIndexPath *indexPath = layoutAttr.indexPath;
        if (indexPath.row < _fetchResult.count) {
            PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}

- (void)addSource:(PHAsset *)asset {
    [self.selectedSource addObject:asset];
}

- (void)removeSource:(PHAsset *)asset {
    [self.selectedSource removeObject:asset];
}

- (void)setCropScale:(CGFloat)cropScale {
    _cropScale = cropScale;
}

- (void)jumpToCrop {
    _isLocalSelected = YES;
    PHAsset * first = [self.selectedSource objectOrNilAtIndex:0];
    if (first == nil) {
        [EJProgressHUD showAlert:@"出错了，请重试" forView:self.view];
        return;
    }
    if (first.mediaType == PHAssetMediaTypeImage) {
        [self.manager requestImageDataForAsset:first options:self.options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (imageData == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [EJProgressHUD showAlert:@"找不到照片了" forView:self.view];
                });
                return;
            }
            UIImage * image = [UIImage imageWithData:imageData];
            EJImageCropperVC * vc = [[EJImageCropperVC alloc] initWithImage:image];
            vc.cropScale = _cropScale;
            vc.delegate = self;
            vc.customCropBorder = _customCropBorder;
            vc.customLayerImage = _customLayerImage;
            vc.warningTitle = _cropWarningTitle;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    } else {
        LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:first defaultDuration:_maxVideoDuration];
        vc.delegate = self;
        [self ej_presentViewController:vc animated:YES completion:nil];
    }
}

- (void)jumpToBrowser:(NSUInteger)currentIndex {
    
    
    // 图片浏览
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    [self.browserSource removeAllObjects];
    for (PHAsset *asset in _fetchResult) {
        [self.browserSource addObject:[EJPhoto photoWithAsset:asset targetSize:imageTargetSize]];
    }
    EJPhotoBrowser * brower = [[EJPhotoBrowser alloc] initWithDelegate:self];
    brower.maxVideoDuration = _maxVideoDuration;
    brower.showCropButton = _allowCrop;
    brower.forcedCrop = _forcedCrop;
    brower.customCropBorder = _customCropBorder;
    brower.customLayerImage = _customLayerImage;
    if (_maxSelectedCount == 1) {
        brower.showSelectButton = NO;
    } else {
        brower.showSelectButton = YES;
    }
    [brower setCurrentPhotoIndex:currentIndex];
    [self.navigationController pushViewController:brower animated:YES];
}

#pragma mark - action
- (void)handleClickLeftItem {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleClickRightItem {
    [self.navigationController pushViewController:self.albumVC animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateAssetsCache];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changeDetail = [changeInstance changeDetailsForFetchResult:_fetchResult];
    if (changeDetail == nil) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.fetchResult = [changeDetail fetchResultAfterChanges];
        if (_maxSelectedCount != 1) {
            if ([_customTitle length] > 0) {
                self.title = _customTitle;
            } else {
                NSString * title = [self.assetCollection.localizedTitle length] > 0 ? self.assetCollection.localizedTitle : @"";
                self.title = [NSString stringWithFormat:@"%@(%d)", title, (int)self.fetchResult.count];
            }
        }
        if (changeDetail.hasIncrementalChanges) {
            UICollectionView * collection = self.collectionView;
            if (collection) {
                if (_showShot && _sortOrder == LSSortOrderDescending) {
                    [self.collectionView reloadData];
                } else {
                    [self.collectionView reloadData];
                }
            } else {
                //
            }
        } else {
            [self.collectionView reloadData];
        }
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_showShot) {
        return [_fetchResult count] + 1;
    }
    return [_fetchResult count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = 0;
    if (_showShot) {
        if (_sortOrder == LSSortOrderDescending) {
            if (indexPath.row == 0) {
                EJImagePickerShotCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EJImagePickerShotCell" forIndexPath:indexPath];
                cell.delegate = self;
                return cell;
            } else {
                index = indexPath.row - 1;
            }
        }
        if (_sortOrder == LSSortOrderAscending) {
            if (indexPath.row == [_fetchResult count]) {
                EJImagePickerShotCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EJImagePickerShotCell" forIndexPath:indexPath];
                cell.delegate = self;
                return cell;
            } else {
                index = indexPath.row;
            }
        }
    } else {
        index = indexPath.row;
    }
    LSAssetItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ls_assetItem_Cell" forIndexPath:indexPath];
    [cell setIsSelectable:(_maxSelectedCount == 1 ? NO : YES)];
    if (index < _fetchResult.count) {
        PHAsset * asset = [_fetchResult objectAtIndex:index];
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            cell.videoLabel.hidden = NO;
            cell.videoLabel.text = [NSString shortedSecond:asset.duration];
        } else {
            cell.videoLabel.hidden = YES;
        }
        if (@available(iOS 9.1, *)) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                cell.livePhotoIcon.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            } else {
                cell.livePhotoIcon.image = nil;
            }
        } else {
            cell.livePhotoIcon.image = nil;
        }
        cell.localIdentifier = asset.localIdentifier;
        [_manager requestImageForAsset:asset targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if ([cell.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.coverImageView.image = result;
            }
        }];
//        if (_maxSelectedCount > 0) {
            cell.sourceSelected = NO;
            [self.selectedSource enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.localIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.sourceSelected = YES;
                    * stop = YES;
                }
            }];
            
            @weakify(cell);
            [cell setUpSelectSourceBlock:^(NSString *clickLocalIdentifier) {
                @strongify(cell);
                if ([self.selectedSource count] == 0) {
                    if (asset.mediaType == PHAssetMediaTypeVideo && asset.duration > _maxVideoDuration) {
                        NSString * secondString;
                        if (_maxVideoDuration < 60) {
                            secondString = [NSString stringWithFormat:@"%d秒", (int)_maxVideoDuration];
                        } else {
                            secondString = [NSString stringWithFormat:@"%d分%d秒", (int )_maxVideoDuration / 60, (int)_maxVideoDuration % 60];
                        }
                        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"仅支持%@以内的视频，是否前往裁剪？", secondString] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        if ([EJPhotoConfig sharedPhotoConfig].alertCancelColor) {
                            [cancelAction setValue:[EJPhotoConfig sharedPhotoConfig].alertCancelColor forKey:@"titleTextColor"];
                        }
                        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            // 跳转到裁剪页面
                            LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:asset defaultDuration:_maxVideoDuration];
                            vc.delegate = self;
                            [self ej_presentViewController:vc animated:YES completion:nil];
                        }];
                        if ([EJPhotoConfig sharedPhotoConfig].alertDefaultColor) {
                            [doneAction setValue:[EJPhotoConfig sharedPhotoConfig].alertDefaultColor forKey:@"titleTextColor"];
                        }
                        [alertC addAction:cancelAction];
                        [alertC addAction:doneAction];
                        [self presentViewController:alertC animated:YES completion:nil];
                        return ;
                    }
                    cell.sourceSelected = YES;
                    [self.selectedSource addObject:asset];
                    [self.toolBar configSourceCount:self.selectedSource.count];
                } else {
                    __block BOOL containSource = NO;
                    [self.selectedSource enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.localIdentifier isEqualToString:clickLocalIdentifier]) {
                            cell.sourceSelected = NO;
                            containSource = YES;
                            *stop = YES;
                        }
                    }];
                    if (containSource) {
                        // 从 数组中移除
                        [self.selectedSource removeObject:asset];
                        [self.toolBar configSourceCount:self.selectedSource.count];
                    } else {
                        // 判断 最大 数量
                        if (self.maxSelectedCount == 0 || [self.selectedSource count] < self.maxSelectedCount) {
                            if (asset.mediaType == PHAssetMediaTypeVideo && asset.duration > _maxVideoDuration) {
                                NSString * secondString;
                                if (_maxVideoDuration < 60) {
                                    secondString = [NSString stringWithFormat:@"%d秒", (int)_maxVideoDuration];
                                } else {
                                    secondString = [NSString stringWithFormat:@"%d分%d秒", (int )_maxVideoDuration / 60, (int)_maxVideoDuration % 60];
                                }
                                UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"仅支持%@以内的视频，是否前往裁剪？", secondString] preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                                if ([EJPhotoConfig sharedPhotoConfig].alertCancelColor) {
                                    [cancelAction setValue:[EJPhotoConfig sharedPhotoConfig].alertCancelColor forKey:@"titleTextColor"];
                                }
                                UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    // 跳转到裁剪页面
                                    LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:asset defaultDuration:_maxVideoDuration];
                                    vc.delegate = self;
                                    [self ej_presentViewController:vc animated:YES completion:nil];
                                }];
                                if ([EJPhotoConfig sharedPhotoConfig].alertDefaultColor) {
                                    [doneAction setValue:[EJPhotoConfig sharedPhotoConfig].alertDefaultColor forKey:@"titleTextColor"];
                                }
                                [alertC addAction:cancelAction];
                                [alertC addAction:doneAction];
                                [self presentViewController:alertC animated:YES completion:nil];
                                return ;
                            }
                            cell.sourceSelected = YES;
                            // 添加 到 数组
                            [self.selectedSource addObject:asset];
                            [self.toolBar configSourceCount:self.selectedSource.count];
                        } else {
                            NSLog(@"已经最大");
                            NSString * string;
                            switch (_sourceType) {
                                case E_SourceType_Image: {
                                    string = [NSString stringWithFormat:@"最多选取%d张照片", (int)self.maxSelectedCount];
                                }
                                    break;
                                case E_SourceType_Video: {
                                    string = [NSString stringWithFormat:@"最多选取%d个视频", (int)self.maxSelectedCount];
                                }
                                    break;
                                case E_SourceType_All: {
                                    string = [NSString stringWithFormat:@"最多选取%d个照片或视频", (int)self.maxSelectedCount];
                                }
                                    break;
                            }
                            [EJProgressHUD showAlert:string forView:self.view];
                            cell.sourceSelected = NO;
                        }
                    }
                }
            }];
//        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 跳转到 图片浏览
    NSUInteger currentIndex = indexPath.row;
    if (_showShot) {
        currentIndex -= 1;
    }
    if (currentIndex < _fetchResult.count) {
        if (_maxSelectedCount == 1 && _allowCrop) {
            [self.selectedSource removeAllObjects];
            if (_directEdit) {
                [self.selectedSource addObject:[_fetchResult objectAtIndex:currentIndex]];
                [self jumpToCrop];
                return;
            }
        }
        [self jumpToBrowser:currentIndex];
    } else {
        [collectionView reloadData];
        [EJProgressHUD showAlert:@"出错了，请重试" forView:self.view];
    }
}

#pragma mark - LSAssetCollectionToolBarDelegate
- (void)ls_assetCollectionToolBarDidClickPreviewButton {
    if ([self.selectedSource count] == 0) {
        return;
    }
    // 跳转到 图片浏览
    NSUInteger currentIndex = 0;
    // 图片浏览
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    [self.browserSource removeAllObjects];
    for (PHAsset *asset in self.selectedSource) {
        [self.browserSource addObject:[EJPhoto photoWithAsset:asset targetSize:imageTargetSize]];
    }
    EJPhotoBrowser * brower = [[EJPhotoBrowser alloc] initWithDelegate:self];
    brower.maxVideoDuration = _maxVideoDuration;
    brower.showSelectButton = YES;
    brower.showCropButton = _allowCrop;
    brower.forcedCrop = _forcedCrop;
    [brower setCurrentPhotoIndex:currentIndex];
    brower.isPreview = YES;
    brower.customCropBorder = _customCropBorder;
    brower.customLayerImage = _customLayerImage;
    [self.navigationController pushViewController:brower animated:YES];
}

- (void)ls_assetCollectionToolBarDidClickOriginalButton:(UIButton *)originalButton {
//    if (originalButton.isSelected) {
//        // 选中原图
//    } else {
//        // 未选中原图
//    }
}

- (void)ls_assetCollectionToolBarDidClickDoneButton {
    // 选择完毕 返回
    if ([self.delegate respondsToSelector:@selector(ej_imagePickerDidSelected:)]) {
        [self.delegate ej_imagePickerDidSelected:self.selectedSource];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EJImagePickerShotCellDelegate
- (void)ej_imagePickerShotCellDidClick:(EJImagePickerShotCell *)cell {
    _isLocalSelected = NO;
    EJ_ShotType shotType = EJ_ShotType_Both;
    switch (_sourceType) {
        case E_SourceType_All: {
            shotType = EJ_ShotType_Both;
        }
            break;
        case E_SourceType_Image: {
            shotType = EJ_ShotType_Photo;
        }
            break;
        case E_SourceType_Video: {
            shotType = EJ_ShotType_Video;
        }
            break;
    }
    if (_sourceType == E_SourceType_All) {
        shotType = EJ_ShotType_Both;
    }
    EJCameraShotVC * vc = [[EJCameraShotVC alloc] initWithShotTime:kVideoShotDuration shotType:shotType delegate:self suggestOrientation:E_VideoOrientationAll /*allowPreview:YES*/ maxCount:1];
    vc.forcedCrop = _forcedCrop;
    vc.directCrop = _directEdit;
    vc.cropScale = _cropScale;
    vc.customCropBorder = _customCropBorder;
    vc.customLayerImage = _customLayerImage;
    vc.cropWarningTitle = _cropWarningTitle;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self ej_presentViewController:nav animated:YES completion:nil];
}

#pragma mark - EJCameraShotVCDelegate
- (void)ej_shotVCDidShot:(NSArray *)assets {
    PHFetchResult <PHAsset *> * assetSource = [PHAsset fetchAssetsWithLocalIdentifiers:assets options:nil];
    [assetSource enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.selectedSource count] < 9) {
            [self.selectedSource addObject:obj];
        }
    }];
    [self.toolBar configSourceCount:self.selectedSource.count];
    [self getAllAssets];
    if (_browserAfterShot) {
        [self jumpToBrowser:0];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void)ej_shotVC:(EJCameraShotVC *)shotVC didCropped:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(ej_imagePicker:didCropped:)]) {
        [self.delegate ej_imagePicker:self didCropped:image];
    }
}

#pragma mark - EJImageCropperDelegate
- (void)ej_imageCropperVCDidCancel {
    if (_isLocalSelected == NO) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            EJCameraShotVC * vc = [[EJCameraShotVC alloc] initWithShotTime:kVideoShotDuration shotType:EJ_ShotType_Photo delegate:self suggestOrientation:E_VideoOrientationAll /*allowPreview:YES*/ maxCount:1];
            vc.forcedCrop = _forcedCrop;
            vc.directCrop = _directEdit;
            vc.cropScale = _cropScale;
            vc.customCropBorder = _customCropBorder;
            vc.customLayerImage = _customLayerImage;
            vc.cropWarningTitle = _cropWarningTitle;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self ej_presentViewController:nav animated:YES completion:nil];
        });
    } else {
    }
}

- (void)ej_imageCropperVCDidCrop:(UIImage *)image isCrop:(BOOL)isCrop {
    if (image) {
        if (_autoPopAfterCrop) {
            if (isCrop) {
                [[LSSaveToAlbum mainSave] saveImage:image successBlock:^(NSString *assetLocalId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([assetLocalId length] > 0) {
                            PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalId] options:nil].firstObject;
                            [self.selectedSource removeAllObjects];
                            [self.selectedSource addObject:asset];
                            if ([self.delegate respondsToSelector:@selector(ej_imagePickerDidSelected:)]) {
                                [self.delegate ej_imagePickerDidSelected:self.selectedSource];
                            }
                            [self dismissViewControllerAnimated:YES completion:nil];
                        } else {
                            [EJProgressHUD showAlert:@"保存失败" forView:self.view];
                        }
                    });
                } failureBlock:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [EJProgressHUD showAlert:error.localizedDescription forView:self.view];
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(ej_imagePickerDidSelected:)]) {
                        [self.delegate ej_imagePickerDidSelected:self.selectedSource];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(ej_imagePicker:didCropped:)]) {
                [self.delegate ej_imagePicker:self didCropped:image];
            }
        }
    } else {
        UIWindow * window = [UIApplication sharedApplication].delegate.window;
        [EJProgressHUD showAlert:@"裁剪失败" forView:window];
    }
}

- (BOOL)ej_imageCropperVCAutoPopAfterCrop {
    return _autoPopAfterCrop;
}

#pragma mark - LSInterceptVideoDelegate
- (void)ls_interceptVideoDidCropVideo:(NSString *)assetLocalId {
    if ([assetLocalId length] > 0) {
        PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalId] options:nil].firstObject;
        [self.selectedSource removeAllObjects];
        [self.selectedSource addObject:asset];
        if ([self.delegate respondsToSelector:@selector(ej_imagePickerDidSelected:)]) {
            [self.delegate ej_imagePickerDidSelected:self.selectedSource];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [EJProgressHUD showAlert:@"保存失败" forView:self.view];
        });
    }
}

#pragma mark - EJPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(EJPhotoBrowser *)photoBrowser {
    return [self.browserSource count];
}

- (id<EJPhoto>)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.browserSource.count)
        return [self.browserSource objectAtIndex:index];
    return nil;
}

- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    EJPhoto * photo = [self.browserSource objectOrNilAtIndex:index];
    if (photo == nil) {
        return NO;
    }
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        return NO;
    }
    for (PHAsset * asset in self.selectedSource) {
        if ([asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    EJPhoto * photo = [self.browserSource objectAtIndex:index];
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        return;
    }
    if (selected) {
        [self.selectedSource addObject:indexAsset];
    } else {
        for (PHAsset * asset in self.selectedSource.reverseObjectEnumerator) {
            if ([asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
                [self.selectedSource removeObject:asset];
                break;
            }
        }
        if (photoBrowser.isPreview && _previewDelete) {
            [self.browserSource removeObject:photo];
            [photoBrowser reloadData];
        }
    }
}

- (BOOL)photoBrowserCanPhotoSelectedAtIndex:(EJPhotoBrowser *)photoBrowser {
    if (_maxSelectedCount == 0 || [self.selectedSource count] < _maxSelectedCount) {
        return YES;
    }
    return NO;
}

- (void)photoBrowserDidFinish:(EJPhotoBrowser *)photoBrowser {
    [self.collectionView reloadData];
    [_toolBar configSourceCount:self.selectedSource.count];
//    if (_maxSelectedCount == 1) {
        [self ls_assetCollectionToolBarDidClickDoneButton];
//    }
}

- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser {
    [self.collectionView reloadData];
    [_toolBar configSourceCount:self.selectedSource.count];
//    if (_maxSelectedCount == 1) {
//    [self ls_assetCollectionToolBarDidClickDoneButton];
//    }
}

- (NSUInteger)photoBrowserSelectedPhotoCount:(EJPhotoBrowser *)photoBrowser {
    return self.selectedSource.count;
}

- (NSUInteger)photoBrowserMaxSelectePhotoCount:(EJPhotoBrowser *)photoBrowser {
    return _maxSelectedCount;
}

- (CGFloat)photoBrowser:(EJPhotoBrowser *)photoBrowser crapScaleAtIndex:(NSUInteger)index {
    return _cropScale;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index assetId:(NSString *)assetId {
    EJPhoto * photo = [self.browserSource objectAtIndex:index];
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        [photoBrowser reloadData];
        return;
    }
    
    PHAsset * currentAsset;
    for (PHAsset * item in self.selectedSource) {
        if ([item.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
            currentAsset = item;
            break;
        }
    }
    PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil] firstObject];
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    EJPhoto * currPhoto = [EJPhoto photoWithAsset:asset targetSize:imageTargetSize];
    if (currentAsset) {
        NSUInteger currentIndex = [self.selectedSource indexOfObject:currentAsset];
        [self.selectedSource replaceObjectAtIndex:currentIndex withObject:asset];
//        if (photoBrowser.isPreview) {
            [self.browserSource replaceObjectAtIndex:index withObject:currPhoto];
//        } else {
//            [self.browserSource insertObject:currPhoto atIndex:0];
//        }
    } else {
        [self.selectedSource addObject:asset];
        [self.browserSource insertObject:currPhoto atIndex:0];
    }
    [photoBrowser reloadData];
}

#pragma mark - getter or setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = _sectionInset;
        layout.itemSize = _itemSize;
        layout.minimumLineSpacing = _itemSpace;
        layout.minimumInteritemSpacing = _itemSpace;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[LSAssetItemCell class] forCellWithReuseIdentifier:@"ls_assetItem_Cell"];
        if (_showShot) {
            [_collectionView registerNib:[UINib nibWithNibName:@"EJImagePickerShotCell" bundle:nil] forCellWithReuseIdentifier:@"EJImagePickerShotCell"];
        }
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (LSAssetCollectionToolBar *)toolBar {
    if (!_toolBar) {
        BOOL isShowOriginal = NO;
//        if (_assetType == LSAssetTypeVideos) {
//            isShowOriginal = NO;
//        }
        _toolBar = [LSAssetCollectionToolBar ls_assetCollectionToolBarWithShowCount:YES showOriginal:isShowOriginal maxCount:_maxSelectedCount showPercentage:YES];
        _toolBar.delegate = self;
        [self.view addSubview:_toolBar];
    }
    return _toolBar;
}

- (NSMutableArray *)selectedSource {
    if (!_selectedSource) {
        _selectedSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _selectedSource;
}

- (EJAlbumPickerVC *)albumVC {
    if (!_albumVC) {
        @weakify(self);
        EJAlbumPickerVC * vc = [[EJAlbumPickerVC alloc] initWithSourceType:_sourceType clickAlbumBlock:^(PHAssetCollection *collection) {
            @strongify(self);
            self.assetCollection = collection;
            [self getAllAssets];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.collectionView scrollToTop];
            });
        }];
        _albumVC = vc;
    }
    return _albumVC;
}

- (NSMutableArray *)browserSource {
    if (!_browserSource) {
        _browserSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _browserSource;
}

@end
