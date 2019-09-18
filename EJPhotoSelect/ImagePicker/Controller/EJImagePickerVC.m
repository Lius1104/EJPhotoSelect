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

#import "EJAssetLinkLocal.h"

@interface EJImagePickerVC ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver, LSAssetCollectionToolBarDelegate, EJImagePickerShotCellDelegate, EJCameraShotVCDelegate, EJPhotoBrowserDelegate, EJImageCropperDelegate, LSInterceptVideoDelegate> {
//    CGRect previousPreheatRect;
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
@property (nonatomic, strong) NSMutableArray <EJAssetLinkLocal *>* assetSource;


@property (nonatomic, assign) BOOL showShot;

@property (nonatomic, assign) BOOL allowCrop;

@property (nonatomic, assign) E_SourceType sourceType;

@property (nonatomic, assign) BOOL singleSelect;
@property (nonatomic, assign) E_SourceType selectedType;//仅在sourceType = .ALL && singleSelect = YES 时有效

@property (nonatomic, assign, readonly) LSSortOrder sortOrder;

@property (nonatomic, assign) NSUInteger maxSelectedCount;

@property (nonatomic, strong) NSMutableArray <EJAssetLinkLocal *>* selectedSource;
@property (nonatomic, strong) NSMutableSet <NSString *>* editSource;


@property (nonatomic, strong) EJAlbumPickerVC * albumVC;

@property (nonatomic, strong) NSMutableArray * browserSource;

@property (nonatomic, assign) BOOL viewAppear;

@property (nonatomic, assign) BOOL needReload;

@end

@implementation EJImagePickerVC

- (instancetype)initWithSourceType:(E_SourceType)sourceType MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray<PHAsset *> *)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop {
    EJImagePickerVC * vc = [[EJImagePickerVC alloc] initWithSourceType:sourceType singleSelect:NO MaxCount:maxCount SelectedSource:selectedSource increaseOrder:increaseOrder showShot:showShot allowCrop:allowCrop];
    
    return vc;
}

- (instancetype)initWithSourceType:(E_SourceType)sourceType singleSelect:(BOOL)singleSelect MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray<PHAsset *> *)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop {
    self = [super init];
    if (self) {
        _needReload = NO;
        _cropScale = 0;
        self.sourceType = sourceType;
        self.singleSelect = singleSelect;
        self.selectedType = E_SourceType_All;
        self.showShot = showShot;
        self.allowCrop = allowCrop;
        self.maxSelectedCount = maxCount;
        self.directEdit = YES;
        self.maxVideoDuration = 180;
        self.previewDelete = YES;
        self.forcedCrop = YES;
        
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
        
        for (PHAsset * asset in selectedSource) {
            EJAssetLinkLocal * link = [[EJAssetLinkLocal alloc] init];
            link.asset = asset;
            [self.selectedSource addObject:link];
        }
    }
    return self;
}

- (void)dealloc {
    NSLog(@"EJImagePickerVC dealloc.");
    [self resetCachedAssets];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorHex(ffffff);
    self.title = @"选择照片视频";
    
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
        [self configSourceCount];
    } else {
        self.toolBar.hidden = YES;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
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
                    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
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
                        if (self.assetSource.count > 0) {
                            NSInteger count = self.assetSource.count;
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
            if (self.assetSource.count > 0) {
                [_collectionView reloadData];
                NSInteger count = self.assetSource.count;
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
                [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }
        }
        self.isNeedScroll = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _viewAppear = YES;
    if (_needReload) {
        _needReload = NO;
        [self.collectionView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _viewAppear = NO;
}

- (void)reloadCollectionData {
    if (self.viewAppear) {
        if ([NSThread isMainThread]) {
            [self.collectionView reloadData];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    } else {
        _needReload = YES;
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
    [self assetToLinkLocal];
    if (_maxSelectedCount != 1) {
        NSString * title = [_assetCollection.localizedTitle length] > 0 ? _assetCollection.localizedTitle : @"";
        self.title = [NSString stringWithFormat:@"%@(%d)", title, (int)self.assetSource.count];
    }
}

- (void)assetToLinkLocal {
    [self.assetSource removeAllObjects];
    [_fetchResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EJAssetLinkLocal * link = [[EJAssetLinkLocal alloc] init];
        link.asset = obj;
        [_assetSource addObject:link];
    }];
}

- (void)resetCachedAssets {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [_manager stopCachingImagesForAllAssets];
    }
//    previousPreheatRect = CGRectZero;
}

//- (void)updateAssetsCache {
//    // self.view.window == nil 判断当前view是否显示在屏幕上
//    if (!self.isViewLoaded || self.view.window == nil) {
//        return;
//    }
//
//    // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
//    CGRect visibleRect = CGRectMake(0.f, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
//    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
//
//    // 只有当可见区域与最后一个预热区域显著不同时才更新
//    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect));
//    if (delta > self.view.bounds.size.height / 3.f) {
//        // 计算开始缓存和停止缓存的区域
//        [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
//            [self imageManagerStopCachingImagesWithRect:removedRect];
//        } addedHandler:^(CGRect addedRect) {
//            [self imageManagerStartCachingImagesWithRect:addedRect];
//        }];
//        previousPreheatRect = preheatRect;
//    }
//}

//- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
//    if (CGRectIntersectsRect(newRect, oldRect)) {
//        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
//        CGFloat oldMinY = CGRectGetMinY(oldRect);
//        CGFloat newMaxY = CGRectGetMaxY(newRect);
//        CGFloat newMinY = CGRectGetMinY(newRect);
//        //添加 向下滑动(往下翻看新的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
//        if (newMaxY > oldMaxY) {
//            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
//            addedHandler(rectToAdd);
//        }
//        //添加 向上滑动(往上翻看之前的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
//        if (oldMinY > newMinY) {
//            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
//            addedHandler(rectToAdd);
//        }
//        //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
//        if (newMaxY < oldMaxY) {
//            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
//            removedHandler(rectToRemove);
//        }
//        //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
//        if (oldMinY < newMinY) {
//            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
//            removedHandler(rectToRemove);
//        }
//    } else {
//        //当 oldRect 与 newRect 没有相交区域时
//        addedHandler(newRect);
//        removedHandler(oldRect);
//    }
//}
//
//- (void)imageManagerStartCachingImagesWithRect:(CGRect)rect {
//    NSMutableArray<PHAsset *> *addAssets = [self indexPathsForElementsWithRect:rect];
//    [_manager startCachingImagesForAssets:addAssets targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:_options];
//}
//
//- (void)imageManagerStopCachingImagesWithRect:(CGRect)rect {
//    NSMutableArray<PHAsset *> *removeAssets = [self indexPathsForElementsWithRect:rect];
//    [_manager stopCachingImagesForAssets:removeAssets targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:_options];
//}
//
//- (NSMutableArray<PHAsset *> *)indexPathsForElementsWithRect:(CGRect)rect {
//    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
//    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributes = [layout layoutAttributesForElementsInRect:rect];
//    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
//    for (__kindof UICollectionViewLayoutAttributes *layoutAttr in layoutAttributes) {
//        NSIndexPath *indexPath = layoutAttr.indexPath;
//        if (indexPath.row < _fetchResult.count) {
//            PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
//            [assets addObject:asset];
//        }
//    }
//    return assets;
//}

//- (void)addSource:(PHAsset *)asset {
//    [self.selectedSource addObject:asset];
//}

//- (void)removeSource:(PHAsset *)asset {
//    [self.selectedSource removeObject:asset];
//}

- (void)setCropScale:(CGFloat)cropScale {
    _cropScale = cropScale;
}

- (void)jumpToCrop {
    _isLocalSelected = YES;
    EJAssetLinkLocal * first = [self.selectedSource firstObject];
    if (first.asset.mediaType == PHAssetMediaTypeImage) {
        [self.manager requestImageDataForAsset:first.asset options:self.options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage * image = [UIImage imageWithData:imageData];
            EJImageCropperVC * vc = [[EJImageCropperVC alloc] initWithImage:image];
            vc.cropScale = _cropScale;
            vc.delegate = self;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
    } else {
        LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:first.asset defaultDuration:_maxVideoDuration];
        vc.delegate = self;
        [self ej_presentViewController:vc animated:YES completion:nil];
    }
}

- (void)jumpToBrowser:(NSUInteger)currentIndex {
    // 图片浏览
    [self.browserSource removeAllObjects];
    for (EJAssetLinkLocal *link in self.assetSource) {
        [self.browserSource addObject:[EJPhoto photoWithAssetLink:link]];
    }
    EJPhotoBrowser * brower = [[EJPhotoBrowser alloc] initWithDelegate:self];
    brower.maxVideoDuration = _maxVideoDuration;
    brower.showCropButton = _allowCrop;
    brower.forcedCrop = _forcedCrop;
    if (_maxSelectedCount == 1) {
        brower.showSelectButton = NO;
    } else {
        brower.showSelectButton = YES;
    }
    [brower setCurrentPhotoIndex:currentIndex];
    [self.navigationController pushViewController:brower animated:YES];
}

- (void)configSourceCount {
    NSUInteger count = self.selectedSource.count;
    NSUInteger oldCount = self.toolBar.currentCount;
    [self.toolBar configSourceCount:count];
    
    if (oldCount >= 1) {// 减
        if (count == 0) {
            _selectedType = E_SourceType_All;
            [self reloadCollectionData];
        }
    } else {//old count = 0 加
        if (count == 1) {
            _selectedType = [self.selectedSource firstObject].asset.mediaType == PHAssetMediaTypeImage ? E_SourceType_Image : E_SourceType_Video;
            [self reloadCollectionData];
        } else if (count == 0) {
            _selectedType = E_SourceType_All;
        } else {// new count > 1
            _selectedType = E_SourceType_All;
            _singleSelect = NO;
            [self reloadCollectionData];
        }
    }
}

#pragma mark - action
- (void)handleClickLeftItem {
    [[NSFileManager defaultManager] removeItemAtPath:[EJAssetLinkLocal rootPath] error:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleClickRightItem {
    [self.navigationController pushViewController:self.albumVC animated:YES];
}

//#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self updateAssetsCache];
//}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changeDetail = [changeInstance changeDetailsForFetchResult:_fetchResult];
    if (changeDetail == nil) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.fetchResult = [changeDetail fetchResultAfterChanges];
        [self assetToLinkLocal];
        if (_maxSelectedCount != 1) {
            NSString * title = [self.assetCollection.localizedTitle length] > 0 ? self.assetCollection.localizedTitle : @"";
            self.title = [NSString stringWithFormat:@"%@(%d)", title, (int)self.assetSource.count];
        }
        if (changeDetail.hasIncrementalChanges) {
            UICollectionView * collection = self.collectionView;
            if (collection) {
                if (_showShot && _sortOrder == LSSortOrderDescending) {
                    [self reloadCollectionData];
                } else {
                    [self reloadCollectionData];
                }
            } else {
            }
        } else {
            [self reloadCollectionData];
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
        return [self.assetSource count] + 1;
    }
    return [self.assetSource count];
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
            if (indexPath.row == [self.assetSource count]) {
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
    if (index < self.assetSource.count) {
        EJAssetLinkLocal * link = [self.assetSource objectAtIndex:index];
        if (link.asset.mediaType == PHAssetMediaTypeVideo) {
            cell.videoLabel.hidden = NO;
            cell.videoLabel.text = [NSString shortedSecond:link.asset.duration];
        } else {
            cell.videoLabel.hidden = YES;
        }
//        if (@available(iOS 9.1, *)) {
//            if (link.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
//                cell.livePhotoIcon.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
//            } else {
//                cell.livePhotoIcon.image = nil;
//            }
//        } else {
//            cell.livePhotoIcon.image = nil;
//        }
        if ([self.editSource containsObject:link.asset.localIdentifier]) {
            cell.editImage.hidden = NO;
            if (cell.videoLabel.isHidden == NO) {
                cell.videoLabel.hidden = YES;
            }
        } else {
            cell.editImage.hidden = YES;
        }
        
        cell.localIdentifier = link.asset.localIdentifier;
        if ([link.localPath length] > 0) {
            cell.coverImageView.image = link.coverImage;
        } else {
            [self.manager requestImageForAsset:link.asset targetSize:_imageSize contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if ([cell.localIdentifier isEqualToString:link.asset.localIdentifier]) {
                    cell.coverImageView.image = result;
                }
            }];
        }
//        if (_maxSelectedCount > 0) {
            cell.sourceSelected = NO;
            [self.selectedSource enumerateObjectsUsingBlock:^(EJAssetLinkLocal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.asset.localIdentifier isEqualToString:link.asset.localIdentifier]) {
                    cell.sourceSelected = YES;
                    * stop = YES;
                }
            }];
            
            @weakify(cell);
            [cell setUpSelectSourceBlock:^(NSString *clickLocalIdentifier) {
                @strongify(cell);
                if ([self.selectedSource count] == 0) {
                    if (link.asset.mediaType == PHAssetMediaTypeVideo && link.asset.duration > _maxVideoDuration) {
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
                            LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:link.asset defaultDuration:_maxVideoDuration];
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
                    [self.selectedSource addObject:link];
                    [self configSourceCount];
                } else {
                    __block BOOL containSource = NO;
                    [self.selectedSource enumerateObjectsUsingBlock:^(EJAssetLinkLocal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.asset.localIdentifier isEqualToString:clickLocalIdentifier]) {
                            cell.sourceSelected = NO;
                            containSource = YES;
                            *stop = YES;
                        }
                    }];
                    if (containSource) {
                        // 从 数组中移除
                        [self.selectedSource removeObject:link];
                        [self configSourceCount];
                    } else {
                        // 判断 最大 数量
                        if (self.maxSelectedCount == 0 || [self.selectedSource count] < self.maxSelectedCount) {
                            if (link.asset.mediaType == PHAssetMediaTypeVideo && link.asset.duration > _maxVideoDuration) {
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
                                    LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:link.asset defaultDuration:_maxVideoDuration];
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
                            [self.selectedSource addObject:link];
                            [self configSourceCount];
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
    if (_maxSelectedCount == 1 && _allowCrop) {
        [self.selectedSource removeAllObjects];
        [self.selectedSource addObject:[self.assetSource objectAtIndex:currentIndex]];
        if (_directEdit) {
            [self jumpToCrop];
            return;
        }
    }
    [self jumpToBrowser:currentIndex];
}

#pragma mark - LSAssetCollectionToolBarDelegate
- (void)ls_assetCollectionToolBarDidClickPreviewButton {
    if ([self.selectedSource count] == 0) {
        return;
    }
    // 跳转到 图片浏览
    NSUInteger currentIndex = 0;
    // 图片浏览
//    UIScreen *screen = [UIScreen mainScreen];
//    CGFloat scale = screen.scale;
//    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
//    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    [self.browserSource removeAllObjects];
    for (EJAssetLinkLocal *obj in self.selectedSource) {
        [self.browserSource addObject:[EJPhoto photoWithAssetLink:obj]];
    }
    EJPhotoBrowser * brower = [[EJPhotoBrowser alloc] initWithDelegate:self];
    brower.maxVideoDuration = _maxVideoDuration;
    brower.showSelectButton = YES;
    brower.showCropButton = _allowCrop;
    brower.forcedCrop = _forcedCrop;
    [brower setCurrentPhotoIndex:currentIndex];
    brower.isPreview = YES;
    [self.navigationController pushViewController:brower animated:YES];
}

- (void)ls_assetCollectionToolBarDidClickOriginalButton:(UIButton *)originalButton {
//    if (originalButton.isSelected) {
//        // 选中原图
//    } else {
//        // 未选中原图
//    }
}

- (void)saveAllSourceAtIndex:(NSUInteger)index resultSource:(NSMutableArray *)resultSource {
    if (index >= [self.selectedSource count]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(ej_imagePickerDidSelected:)]) {
                [self.delegate ej_imagePickerDidSelected:resultSource];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        });
        return;
    }
    EJAssetLinkLocal * obj = [self.selectedSource objectAtIndex:index];
    if ([obj.localPath length] > 0) {
        NSString * filePath = [[EJAssetLinkLocal rootPath] stringByAppendingPathComponent:obj.localPath];
        if (obj.asset.mediaType == PHAssetMediaTypeImage) {
            [[LSSaveToAlbum mainSave] saveImageWithUrl:[NSURL fileURLWithPath:filePath] successBlock:^(NSString *assetLocalId) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalId] options:nil] lastObject];
                [resultSource addObject:asset];
                [self saveAllSourceAtIndex:(index + 1) resultSource:resultSource];
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.domain == NSCocoaErrorDomain && error.code == 2047) {
                        [self deniedAuthAlertTitle:@"您拒绝app访问相册导致操作失败，如需访问请点击\"前往\"打开权限" authBlock:nil];
                    }
                });
            }];
        } else if (obj.asset.mediaType == PHAssetMediaTypeVideo) {
            [[LSSaveToAlbum mainSave] saveVideoWithUrl:[NSURL fileURLWithPath:filePath] successBlock:^(NSString *assetLocalId) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalId] options:nil] lastObject];
                [resultSource addObject:asset];
                [self saveAllSourceAtIndex:(index + 1) resultSource:resultSource];
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.domain == NSCocoaErrorDomain && error.code == 2047) {
                        [self deniedAuthAlertTitle:@"您拒绝app访问相册导致操作失败，如需访问请点击\"前往\"打开权限" authBlock:nil];
                    }
                });
            }];
        } else {
            [self saveAllSourceAtIndex:(index + 1) resultSource:resultSource];
        }
    } else {
        [resultSource addObject:obj.asset];
        [self saveAllSourceAtIndex:(index + 1) resultSource:resultSource];
    }
}

- (void)ls_assetCollectionToolBarDidClickDoneButton {
    // 选择完毕 返回
    NSMutableArray * resultSource = [NSMutableArray arrayWithCapacity:1];
    [self saveAllSourceAtIndex:0 resultSource:resultSource];
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
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self ej_presentViewController:nav animated:YES completion:nil];
}

#pragma mark - EJCameraShotVCDelegate
- (void)ej_shotVCDidShot:(NSArray *)assets {
    PHFetchResult <PHAsset *> * assetSource = [PHAsset fetchAssetsWithLocalIdentifiers:assets options:nil];
    [assetSource enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.selectedSource count] < 9) {
            EJAssetLinkLocal * link = [[EJAssetLinkLocal alloc] init];
            link.asset = obj;
            [self.selectedSource addObject:link];
        }
    }];
    [self configSourceCount];
    [self getAllAssets];
    if (_browserAfterShot) {
        [self jumpToBrowser:0];
    } else {
        [self reloadCollectionData];
    }
}

#pragma mark - EJImageCropperDelegate
- (void)ej_imageCropperVCDidCancel {
    if (_isLocalSelected == NO) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            EJCameraShotVC * vc = [[EJCameraShotVC alloc] initWithShotTime:kVideoShotDuration shotType:EJ_ShotType_Photo delegate:self suggestOrientation:E_VideoOrientationAll /*allowPreview:YES*/ maxCount:1];
            vc.forcedCrop = _forcedCrop;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self ej_presentViewController:nav animated:YES completion:nil];
        });
    } else {
    }
}

- (void)ej_imageCropperVCDidCrop:(UIImage *)image isCrop:(BOOL)isCrop {
    if (image == nil) {
        return;
    }
    if (isCrop) {
        [[LSSaveToAlbum mainSave] saveImage:image successBlock:^(NSString *assetLocalId) {
            PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetLocalId] options:nil] lastObject];
            [self.selectedSource removeAllObjects];
            EJAssetLinkLocal * link = [[EJAssetLinkLocal alloc] init];
            link.asset = asset;
            [self.selectedSource addObject:link];
            NSMutableArray * resultSource = [NSMutableArray arrayWithCapacity:1];
            [self saveAllSourceAtIndex:0 resultSource:resultSource];
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.domain == NSCocoaErrorDomain && error.code == 2047) {
                    [self deniedAuthAlertTitle:@"您拒绝app访问相册导致操作失败，如需访问请点击\"前往\"打开权限" authBlock:nil];
                } else {
                    [EJProgressHUD showAlert:@"保存失败！" forView:self.view];
                }
            });
        }];
    } else {
        NSMutableArray * resultSource = [NSMutableArray arrayWithCapacity:1];
        [self saveAllSourceAtIndex:0 resultSource:resultSource];
    }
}

#pragma mark - LSInterceptVideoDelegate
- (void)ls_interceptVideoDidCropVideo:(NSString *)localPath {
    if ([localPath length] == 0) {
        if (_maxSelectedCount == 1) {
            NSMutableArray * resultSource = [NSMutableArray arrayWithCapacity:1];
            [self saveAllSourceAtIndex:0 resultSource:resultSource];
        }
        return;
    }
    if (_maxSelectedCount == 1) {
        EJAssetLinkLocal * link = [self.selectedSource firstObject];
        link.localPath = localPath;
        NSMutableArray * resultSource = [NSMutableArray arrayWithCapacity:1];
        [self saveAllSourceAtIndex:0 resultSource:resultSource];
    } else {
        BOOL isContains = NO;
        NSString * localId = [[[localPath componentsSeparatedByString:@"."] firstObject] stringByReplacingOccurrencesOfString:@"*" withString:@"/"];
        for (EJAssetLinkLocal * item in self.selectedSource) {
            if ([item.asset.localIdentifier isEqualToString:localId]) {
                item.localPath = localPath;
                [self.editSource addObject:item.asset.localIdentifier];
                isContains = YES;
            }
        }
        if (isContains == NO) {
            EJAssetLinkLocal * link = [[EJAssetLinkLocal alloc] init];
            link.asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil] lastObject];
            link.localPath = localPath;
            [self.editSource addObject:link.asset.localIdentifier];
            [self.selectedSource addObject:link];
        }
        [self configSourceCount];
        [self reloadCollectionData];
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
        if (photo.photoURL) {
            NSString * localPath = [[[photo.photoURL lastPathComponent] componentsSeparatedByString:@"."] firstObject];
            for (EJAssetLinkLocal * link in self.selectedSource) {
                if ([link.localPath rangeOfString:localPath].location != NSNotFound) {
                    return YES;
                }
            }
        }
    } else {
        for (EJAssetLinkLocal * link in self.selectedSource) {
            if ([link.asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    EJPhoto * photo = [self.browserSource objectOrNilAtIndex:index];
    if (photo == nil) {
        return;
    }
//    PHAsset * indexAsset = photo.asset;
    NSString * localId;
    if (photo.asset) {
        localId = photo.asset.localIdentifier;
    } else if (photo.photoURL) {
        localId = [[photo.photoURL lastPathComponent] stringByReplacingOccurrencesOfString:@"*" withString:@"/"];
    }
    if ([localId length] == 0) {
        return;
    }
    if (selected) {
        for (EJAssetLinkLocal * obj in self.assetSource) {
            if ([obj.asset.localIdentifier isEqualToString:localId]) {
                [self.selectedSource addObject:obj];
                break;
            }
        }
    } else {
        for (EJAssetLinkLocal * obj in self.selectedSource.reverseObjectEnumerator) {
            if ([obj.asset.localIdentifier isEqualToString:localId]) {
                [self.selectedSource removeObject:obj];
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
    [self reloadCollectionData];
    [self configSourceCount];
    [self ls_assetCollectionToolBarDidClickDoneButton];
}

- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser {
    [self reloadCollectionData];
    [self configSourceCount];
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

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index localPath:(NSString *)localPath {
    EJPhoto * photo = [self.browserSource objectAtIndex:index];
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        [photoBrowser reloadData];
        return;
    }
    
    EJAssetLinkLocal * currentLink;
    for (EJAssetLinkLocal * item in self.selectedSource) {
        if ([item.asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
            currentLink = item;
            break;
        }
    }
    if (currentLink) {
        currentLink.localPath = localPath;
        if (![self.assetSource containsObject:currentLink]) {
            
            for (EJAssetLinkLocal * obj in self.assetSource) {
                if ([obj.asset.localIdentifier isEqualToString:currentLink.asset.localIdentifier]) {
                    NSUInteger totalIndex = [self.assetSource indexOfObject:obj];
                    [self.assetSource replaceObjectAtIndex:totalIndex withObject:currentLink];
                    break;
                }
            }
        }
    } else {
        for (EJAssetLinkLocal * obj in self.assetSource) {
            if ([obj.asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
                currentLink = obj;
                break;
            }
        }
        
        if (currentLink) {
            currentLink.localPath = localPath;
            [self.selectedSource addObject:currentLink];
        }
    }
    [self.editSource addObject:currentLink.asset.localIdentifier];
    EJPhoto * currPhoto = [EJPhoto photoWithAssetLink:currentLink];
    [self.browserSource replaceObjectAtIndex:index withObject:currPhoto];
    [photoBrowser reloadData];
}

- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoEditedAtIndex:(NSUInteger)index {
    EJPhoto * photo = [self.browserSource objectOrNilAtIndex:index];
    if (photo == nil) {
        return NO;
    }
    if (photo.photoURL) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoReductionAtIndex:(NSUInteger)index {
    EJPhoto * photo = [self.browserSource objectOrNilAtIndex:index];
    if (photo == nil) {
        return;
    }
    if (photo.photoURL == nil) {
        return;
    }
    NSString * localPath = [photo.photoURL lastPathComponent];
//    localPath = [localPath stringByReplacingOccurrencesOfString:@"*" withString:@"/"];
    EJAssetLinkLocal * link;
    for (EJAssetLinkLocal * obj in self.assetSource) {
        if ([obj.localPath isEqualToString:localPath]) {
            link = obj;
            break;
        }
    }
    if (link) {
        link.localPath = nil;
        EJPhoto * currPhoto = [EJPhoto photoWithAssetLink:link];
        [self.browserSource replaceObjectAtIndex:index withObject:currPhoto];
    } else {
        [self.browserSource removeObjectAtIndex:index];
    }
    localPath = [[[localPath stringByReplacingOccurrencesOfString:@"*" withString:@"/"] componentsSeparatedByString:@"."] firstObject];
    if ([self.editSource containsObject:localPath]) {
        [self.editSource removeObject:localPath];
    }
    [self reloadCollectionData];
    [photoBrowser reloadData];
}

#pragma mark - getter or setter
- (PHCachingImageManager *)manager {
    if (!_manager) {
        _manager = [[PHCachingImageManager alloc] init];
    }
    return _manager;
}

- (PHImageRequestOptions *)options {
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return _options;
}

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
        _toolBar = [LSAssetCollectionToolBar ls_assetCollectionToolBarWithShowCount:YES showOriginal:isShowOriginal maxCount:_maxSelectedCount showPercentage:YES];
        _toolBar.delegate = self;
        [self.view addSubview:_toolBar];
    }
    return _toolBar;
}

- (NSMutableArray<EJAssetLinkLocal *> *)assetSource {
    if (!_assetSource) {
        _assetSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _assetSource;
}

- (NSMutableSet<NSString *> *)editSource {
    if (!_editSource) {
        _editSource = [NSMutableSet setWithCapacity:1];
    }
    return _editSource;
}

- (NSMutableArray<EJAssetLinkLocal *> *)selectedSource {
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
