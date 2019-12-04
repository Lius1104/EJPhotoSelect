//
//  ViewController.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/18.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "ViewController.h"
#import "EJImagePickerNVC.h"
#import "EJVideoPlayerVC.h"
#import "EJAddCell.h"
#import "EJSelectedCell.h"
#import "EJPhotoBrowser.h"
#import "EJCameraShotVC.h"

#import "EJConfigModel.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, EJImagePickerVCDelegate, EJPhotoBrowserDelegate, EJCameraShotVCDelegate> {
    EJConfigModel * _config;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * browserSource;

@property (nonatomic, strong) EJProgressHUD * hud;

@end

@implementation ViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat width = floor((self.view.bounds.size.width - 3 * 4) / 3.f);
    self.layout.itemSize = CGSizeMake(width, width);
    self.layout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    self.layout.minimumLineSpacing = 3;
    self.layout.minimumInteritemSpacing = 3;
    [self.collectionView registerNib:[UINib nibWithNibName:@"EJAddCell" bundle:nil] forCellWithReuseIdentifier:@"EJAddCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EJSelectedCell" bundle:nil] forCellWithReuseIdentifier:@"EJSelectedCell"];
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _config = [[EJConfigModel alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConfigDone:) name:@"Config" object:nil];
}

- (IBAction)handleClickUpload:(UIBarButtonItem *)sender {
    BOOL isEnoughFree = [UIDevice isEnoughFreeSizePer:0.1];
    if (!isEnoughFree) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"手机存储空间不足，\n请先清理空间后再次尝试！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
}

#pragma mark - action
- (void)handleConfigDone:(NSNotification *)notification {
    NSDictionary * userInfo = notification.userInfo;
    _config = userInfo[@"Config"];
    [self.dataSource removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource count] < 9 ? self.dataSource.count + 1 : self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource count] < 9 && indexPath.row == self.dataSource.count) {
        EJAddCell * addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EJAddCell" forIndexPath:indexPath];
        return addCell;
    }
    EJSelectedCell * selectedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EJSelectedCell" forIndexPath:indexPath];
    PHAsset * asset = [self.dataSource objectAtIndex:indexPath.row];
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        selectedCell.coverImage.image = [UIImage imageWithData:imageData];
    }];
    [selectedCell configClickDeleteBlock:^{
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.collectionView reloadData];
    }];
    return selectedCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EJAddCell class]]) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * shotAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            EJ_ShotType shotType = EJ_ShotType_Both;
            if (_config.sourceType == E_SourceType_Image) {
                shotType = EJ_ShotType_Photo;
            }
            if (_config.sourceType == E_SourceType_Video) {
                shotType = EJ_ShotType_Video;
            }
            NSUInteger maxCount = (_config.maxSelectCount == 0 ? NSUIntegerMax : _config.maxSelectCount);
            EJCameraShotVC * vc = [[EJCameraShotVC alloc] initWithShotTime:_config.videoDefaultDuration shotType:shotType delegate:self suggestOrientation:E_VideoOrientationPortrait maxCount:maxCount];
            vc.forcedCrop = _config.forcedCrop;
            vc.cropScale = _config.cropScale;
            vc.allowBoth = NO;
            vc.videoShotCount = 1;
            vc.directCrop = YES;
            vc.customCropBorder = [UIImage imageNamed:@"touxiang"];
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self ej_presentViewController:nav animated:YES completion:nil];
        }];
        UIAlertAction * localAction = [UIAlertAction actionWithTitle:@"从本地选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 跳转到 本地照片选择
            E_SourceType sourceType = (E_SourceType)_config.sourceType;
            if (_config.maxSelectCount == 1) {
                [self.dataSource removeAllObjects];
            }
            EJImagePickerNVC * vc = [[EJImagePickerNVC alloc] initWithSourceType:sourceType MaxCount:_config.maxSelectCount SelectedSource:self.dataSource increaseOrder:_config.increaseOrder showShot:_config.allowShot allowCrop:_config.allowCrop];
            if (_config.allowCrop) {
                vc.directEdit = _config.directEdit;
                vc.cropScale = _config.cropScale;
                vc.maxVideoDuration = _config.videoDefaultDuration;
            }
            vc.previewDelete = _config.previewDelete;
            vc.forcedCrop = _config.forcedCrop;
            vc.autoPopAfterCrop = NO;
            // ui
            [vc configSectionInserts:_config.sectionInsets cellSpace:_config.cellSpace numOfLineCells:_config.numOfLineCells];
            
            // delegate
            vc.pickerDelegate = self;
            [self ej_presentViewController:vc animated:YES completion:nil];
        }];
        [alertC addAction:shotAction];
        [alertC addAction:localAction];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    // 照片浏览
    if ([cell isKindOfClass:[EJSelectedCell class]]) {
        UIScreen *screen = [UIScreen mainScreen];
        CGFloat scale = screen.scale;
        CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
        CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
        self.browserSource = [NSMutableArray arrayWithCapacity:1];
        for (PHAsset * asset in self.dataSource) {
            EJPhoto * photo = [EJPhoto photoWithAsset:asset targetSize:imageTargetSize];
            [self.browserSource addObject:photo];
        }
        EJPhotoBrowser * browser = [[EJPhotoBrowser alloc] initWithDelegate:self];
        browser.maxVideoDuration = _config.videoDefaultDuration;
        browser.showSelectButton = YES;
        browser.showCropButton = _config.allowCrop;
        browser.forcedCrop = _config.forcedCrop;
        [browser setCurrentPhotoIndex:indexPath.row];
        browser.isPreview = YES;
        [self.navigationController pushViewController:browser animated:YES];
        return;
    }
}

#pragma mark - EJPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(EJPhotoBrowser *)photoBrowser {
    return [self.browserSource count];
}

- (id<EJPhoto>)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.browserSource objectAtIndex:index];
}

- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    EJPhoto * photo = [self.browserSource objectAtIndex:index];
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        return NO;
    }
    for (PHAsset * asset in self.dataSource) {
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
        [self.dataSource addObject:indexAsset];
    } else {
        for (PHAsset * asset in self.dataSource.reverseObjectEnumerator) {
            if ([asset.localIdentifier isEqualToString:indexAsset.localIdentifier]) {
                [self.dataSource removeObject:asset];
                break;
            }
        }
        if (photoBrowser.isPreview && _config.previewDelete) {
            [self.browserSource removeObject:photo];
            [photoBrowser reloadData];
        }
    }
}

- (BOOL)photoBrowserCanPhotoSelectedAtIndex:(EJPhotoBrowser *)photoBrowser {
    return YES;
}

- (void)photoBrowserDidFinish:(EJPhotoBrowser *)photoBrowser {
    [self.collectionView reloadData];
}

- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser {
    [self.collectionView reloadData];
}

- (NSUInteger)photoBrowserSelectedPhotoCount:(EJPhotoBrowser *)photoBrowser {
    return self.dataSource.count;
}

- (NSUInteger)photoBrowserMaxSelectePhotoCount:(EJPhotoBrowser *)photoBrowser {
    return _config.maxSelectCount;
}

- (CGFloat)photoBrowser:(EJPhotoBrowser *)photoBrowser crapScaleAtIndex:(NSUInteger)index {
    return _config.cropScale;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index assetId:(NSString *)assetId {
    EJPhoto * photo = [self.browserSource objectAtIndex:index];
    PHAsset * indexAsset = photo.asset;
    if (indexAsset == nil) {
        [photoBrowser reloadData];
        return;
    }
    
    PHAsset * currentAsset;
    for (PHAsset * item in self.dataSource) {
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
        NSUInteger currentIndex = [self.dataSource indexOfObject:currentAsset];
        [self.dataSource replaceObjectAtIndex:currentIndex withObject:asset];
        if (photoBrowser.isPreview) {
            [self.browserSource replaceObjectAtIndex:currentIndex withObject:currPhoto];
        } else {
            [self.browserSource insertObject:currPhoto atIndex:0];
        }
    } else {
        [self.dataSource addObject:asset];
        [self.browserSource insertObject:currPhoto atIndex:0];
    }
    [photoBrowser reloadData];
}

#pragma mark - EJCameraShotVCDelegate
- (void)ej_shotVCDidShot:(NSArray *)assets {
    PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:assets options:nil];
    [self.dataSource removeAllObjects];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.dataSource addObject:obj];
    }];
    [self.collectionView reloadData];
}

- (void)ej_shotVC:(EJCameraShotVC *)shotVC didCropped:(UIImage *)image {
    UIWindow * window = [UIApplication sharedApplication].delegate.window;
    _hud = [EJProgressHUD ej_showHUDAddToView:window animated:YES];
    _hud.label.text = @"头像上传中...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud hideAnimated:YES];
        [shotVC dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - EJImagePickerVCDelegate
- (void)ej_imagePickerVC:(EJImagePickerNVC *)imagePicker didSelectedSource:(NSMutableArray *)source {
    self.dataSource = source;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)ej_imagePickerVC:(EJImagePickerNVC *)imagePicker didCroppedImage:(UIImage *)image {
    UIWindow * window = [UIApplication sharedApplication].delegate.window;
    _hud = [EJProgressHUD ej_showHUDAddToView:window animated:YES];
    _hud.label.text = @"头像上传中...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_hud hideAnimated:YES];
        
        [imagePicker dismissViewControllerAnimated:NO completion:^{
            [imagePicker dismissViewControllerAnimated:YES completion:nil];
        }];
    });
}

#pragma mark - getter or setter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}
    
@end
