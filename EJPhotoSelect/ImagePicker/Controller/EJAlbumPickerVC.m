//
//  EJAlbumPickerVC.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJAlbumPickerVC.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "EJ_AlbumModel.h"
#import "ImagePickerEnums.h"
#import "EJImageManager.h"
#import "LSAlbumListCell.h"
#import "UIFont+EJAdd.h"

typedef void(^PHCoverImageBlock)(UIImage * coverImg);

@interface EJAlbumPickerVC ()<UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray <EJ_AlbumModel *>* albumSource;

@property (nonatomic, strong) PHFetchResult <PHAssetCollection *>* smartAlbums;

@property (nonatomic, strong) PHFetchResult <PHAssetCollection *>* userAlbums;

@property (nonatomic, strong) PHAssetCollection * userLibrary;

@property (nonatomic, assign) E_SourceType assetType;

@property (nonatomic, copy) ClickAlbumBlock block;

@end

@implementation EJAlbumPickerVC

- (instancetype)initWithSourceType:(E_SourceType)sourceType clickAlbumBlock:(ClickAlbumBlock)block {
    self = [super init];
    if (self) {
        _assetType = sourceType;
        if (block) {
            self.block = [block copy];
        }
    }
    return self;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColorHex(1C1C1E);
            } else {
                return UIColorHex(ffffff);
            }
        }];
    } else {
        // Fallback on earlier versions
        self.view.backgroundColor = UIColorHex(ffffff);
    }
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    // 跳转到 所有照片中
//    [self jumpToAlbum:_userLibrary animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 获取所有相册
    [self getAllAssetCollections];
    [self.tableView reloadData];
}

#pragma mark - private
- (void)getAllAssetCollections {
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    _userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [self updateAlbums];
}

- (void)updateAlbums {
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    switch (_assetType) {
        case E_SourceType_All: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
            break;
        case E_SourceType_Image: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
            break;
        case E_SourceType_Video: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
            break;
    }
    
    [self.albumSource removeAllObjects];
    for (PHAssetCollection * assetCollection in _smartAlbums) {
        if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) continue;
        if (assetCollection.assetCollectionSubtype == 1000000201) continue; //『最近删除』相册
        PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSUInteger count = result.count;
        if (count == 0) {
            continue;
        }
        EJ_AlbumModel * album = [[EJ_AlbumModel alloc] init];
        album.assetCollection = assetCollection;
        album.sourceCount = count;
        if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            _userLibrary = assetCollection;
            [self.albumSource insertObject:album atIndex:0];
        } else {
            [self.albumSource addObject:album];
        }
        if (album.sourceCount > 0) {
            // 获取 相册封面
            @weakify(self);
            [self getAssetCollection:assetCollection coverImg:^(UIImage *coverImg) {
                album.coverImg = coverImg;
                [weak_self.tableView reloadData];
            }];
        }
    }
    for (PHAssetCollection * assetCollection in _userAlbums) {
        PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        NSUInteger count = result.count;
        if (count > 0) {
            EJ_AlbumModel * album = [[EJ_AlbumModel alloc] init];
            album.assetCollection = assetCollection;
            album.sourceCount = count;
            [self.albumSource addObject:album];
            // 获取 相册封面
            @weakify(self);
            [self getAssetCollection:assetCollection coverImg:^(UIImage *coverImg) {
                album.coverImg = coverImg;
                [weak_self.tableView reloadData];
            }];
        }
    }
}

- (void)getAssetCollection:(PHAssetCollection *)assetCollection coverImg:(PHCoverImageBlock)coverImageBlock {
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    switch (_assetType) {
        case E_SourceType_All: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
            break;
        case E_SourceType_Image: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
            break;
        case E_SourceType_Video: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
            break;
    }
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
    if (fetchResult.count <= 0) {
        coverImageBlock(nil);
        return;
    }
    
    PHAsset * asset = [fetchResult lastObject];
    [[EJImageManager manager].cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(120, 120) contentMode:PHImageContentModeAspectFill options:[EJImageManager manager].imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        coverImageBlock(result);
    }];
}

- (void)jumpToAlbum:(PHAssetCollection *)assetCollection animated:(BOOL)animated {
    if (_block) {
        self.block(assetCollection);
    }
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        PHFetchResultChangeDetails * changeDetail = [changeInstance changeDetailsForFetchResult:self.smartAlbums];
        if (changeDetail) {
            self.smartAlbums = changeDetail.fetchResultAfterChanges;
        }
        changeDetail = [changeInstance changeDetailsForFetchResult:self.userAlbums];
        if (changeDetail) {
            self.userAlbums = changeDetail.fetchResultAfterChanges;
        }
        [self updateAlbums];
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.albumSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSAlbumListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ls_assetCollectionList_cell"];
    if (cell == nil) {
        cell = [[LSAlbumListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ls_assetCollectionList_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.intoImageView.image = [UIImage imageNamed:@"public_icon_more"];
    }
    
    EJ_AlbumModel * album = self.albumSource[indexPath.row];
    [cell setUpCoverImage:album.coverImg];
    NSString * title = [album.assetCollection.localizedTitle length] > 0 ? album.assetCollection.localizedTitle : @"";
    NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont ej_pingFangSCBoldOfSize:14], NSForegroundColorAttributeName: UIColorHex(333333)}];
    NSAttributedString * countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%d)", (int)album.sourceCount] attributes:@{NSFontAttributeName: [UIFont ej_pingFangSCRegularOfSize:14], NSForegroundColorAttributeName: UIColorHex(666666)}];
    [titleString appendAttributedString:countString];
    cell.titleLabel.attributedText = titleString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _albumSource.count) {
        EJ_AlbumModel * album = _albumSource[indexPath.row];
        [self jumpToAlbum:album.assetCollection animated:YES];
    }
}

#pragma mark - getter or setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray<EJ_AlbumModel *> *)albumSource {
    if (!_albumSource) {
        _albumSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _albumSource;
}

@end
