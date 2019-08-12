//
//  EJPhotoBrowser.m
//  EJPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//


#import "EJPhotoBrowser.h"
#import "EJPhotoBrowserPrivate.h"
#import "EJPhotoSelectDefine.h"

#import "EJImageCropperVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import <LSToolsKit/LSToolsKit.h>
#import <EJTools/EJTools.h>
#import <SDWebImage/SDWebImage.h>

#import "EJVideoPlayerVC.h"
#import "LSInterceptVideo.h"

#define PADDING                  0//10

static void * EJVideoPlayerObservation = &EJVideoPlayerObservation;

@interface EJPhotoBrowser ()<EJImageCropperDelegate, EJVideoPlayerDelegate, LSInterceptVideoDelegate>

@property (nonatomic, strong) EJProgressHUD * progressHUD;

@end

@implementation EJPhotoBrowser

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithDelegate:(id <EJPhotoBrowserDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
	}
	return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [self init])) {
		_fixedPhotosArray = photosArray;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
	}
	return self;
}

- (void)_initialisation {
    
    // Defaults
    _isPreview = NO;
//    _previewDelete = NO;
    _forcedCrop = YES;
    
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
    self.hidesBottomBarWhenPushed = YES;
    _hasBelongedToViewController = NO;
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _currentVideoIndex = NSUIntegerMax;
    _displayActionButton = YES;
    _displayNavArrows = NO;
    _zoomPhotosToFill = YES;
    _performingLayout = NO; // Reset on view did appear
    _viewIsActive = NO;
    _delayToHideElements = 5;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
//    _currentGridContentOffset = CGPointMake(0, CGFLOAT_MAX);
    _didSavePreviousStateOfNavBar = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Listen for EJPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEJPhotoLoadingDidEndNotification:)
                                                 name:EJPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
    
}

- (void)dealloc {
    [self clearCurrentVideo];
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos:NO];
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
}

- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            [p unloadUnderlyingImage];
        }
    }
    // Release thumbs
    copy = [_thumbPhotos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            [p unloadUnderlyingImage];
        }
    }
}

- (void)didReceiveMemoryWarning {

	// Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos:YES];
	[_recycledPages removeAllObjects];
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

#pragma mark - View Loading

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    self.fd_prefersNavigationBarHidden = YES;
	// View
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
	
    [self setupSubviews];
    
    // Update
    [self reloadData];
    
    // Swipe to dismiss
//    if (_enableSwipeToDismiss) {
//        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(doneButtonPressed:)];
//        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
//        [self.view addGestureRecognizer:swipeGesture];
//    }
	[super viewDidLoad];
}

- (void)setupSubviews {
    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    [_pagingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.bottom.equalTo(self.view.mas_bottom);
            make.right.equalTo(self.view.mas_right);
        }
    }];
    
    _navigationBar = [[UIView alloc] init];
    _navigationBar.backgroundColor = [UIColorHex(010101) colorWithAlphaComponent:0.94];
    [self configNavigationBar];
    [self.view addSubview:_navigationBar];
    
    [_navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(kToolsNavStatusHeight);
    }];
    
    _bottomBar = [[UIView alloc] init];
    _bottomBar.backgroundColor = [UIColorHex(010101) colorWithAlphaComponent:0.94];
    [self configBottomBar];
    [self.view addSubview:_bottomBar];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kToolsBottomSafeHeight + 42);
    }];
}

- (void)configNavigationBar {
//    UIView *bottomLine = [[UIView alloc] init];
//    bottomLine.backgroundColor = kLineColor;
//    [_navigationBar addSubview:bottomLine];
//    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(_navigationBar);
//        make.height.mas_equalTo(0.5);
//    }];
    
    _backItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backItem setImage:[UIImage imageNamed:@"ejtools_back"] forState:UIControlStateNormal];
    [_backItem addTarget:self action:@selector(handleClickBackItem) forControlEvents:UIControlEventTouchUpInside];
    _backItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_navigationBar addSubview:_backItem];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"预览";
    [_navigationBar addSubview:_titleLabel];
    
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_selectButton setImage:[UIImage imageNamed:@"imagePicker_icon_normal"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"imagePicker_icon_selected"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(handleClickSelectButton) forControlEvents:UIControlEventTouchUpInside];
    [_navigationBar addSubview:_selectButton];
    _selectButton.hidden = !_showSelectButton;
    
    _backItem.frame = CGRectMake(8, kToolsStatusHeight, 25, kToolsNavStatusHeight - kToolsStatusHeight);
    _selectButton.frame = CGRectMake(self.view.width - 30 - 13, kToolsStatusHeight, 30, 30);
    _selectButton.centerY = _backItem.centerY;
    
    _titleLabel.frame = CGRectMake(_backItem.right + 10, _backItem.top, _selectButton.left - 10 - _backItem.right - 10, _backItem.height);
}

- (void)configBottomBar {
//    UIView * topLine = [[UIView alloc] init];
//    topLine.backgroundColor = kLineColor;
//    [_bottomBar addSubview:topLine];
//    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.equalTo(_bottomBar);
//        make.height.mas_equalTo(0.5);
//    }];
    
    
    if (_showCropButton) {
        _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cropButton setTitle:@"编辑" forState:UIControlStateNormal];
        _cropButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cropButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cropButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cropButton addTarget:self action:@selector(handleClickCropButton) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBar addSubview:_cropButton];
    }
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"btn_normal"] forState:UIControlStateNormal];
    [_doneButton setBackgroundImage:[UIImage imageNamed:@"btn_disabled"] forState:UIControlStateDisabled];
    if ([self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
        NSUInteger maxCount = [self.delegate photoBrowserMaxSelectePhotoCount:self];
        if (maxCount != 1) {
            _doneButton.enabled = NO;
        }
    }
    [_doneButton addTarget:self action:@selector(handleClickDoneButton) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBar addSubview:_doneButton];
    
    _cropButton.frame = CGRectMake(14, 0, 45, 42);
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bottomBar.mas_right).offset(-13);
        make.height.mas_equalTo(27);
        make.width.mas_greaterThanOrEqualTo(50);
        make.top.equalTo(_bottomBar.mas_top).offset(6);
//        make.centerY.equalTo(_bottomBar);
    }];
}

- (void)configDoneButton {
    if (_showSelectButton) {
        NSString * title = @"确定";
        if ([self.delegate respondsToSelector:@selector(photoBrowserSelectedPhotoCount:)] && [self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
            NSUInteger selectedCount = [self.delegate photoBrowserSelectedPhotoCount:self];
            NSUInteger maxCount = [self.delegate photoBrowserMaxSelectePhotoCount:self];
            if (selectedCount == maxCount && maxCount == 1) {
            } else {
                title = [title stringByAppendingString:[NSString stringWithFormat:@"(%d", (int)selectedCount]];
            }
            if (maxCount == NSUIntegerMax || maxCount == 0) {
                title = [title stringByAppendingString:@")"];
            } else if (maxCount == 1) {
                
            } else {
                title = [title stringByAppendingString:[NSString stringWithFormat:@"/%d)", (int)maxCount]];
            }
            if (selectedCount == 0) {
                _doneButton.enabled = NO;
                [_doneButton setTitle:@"确定" forState:UIControlStateDisabled];
            } else {
                _doneButton.enabled = YES;
                [_doneButton setTitle:title forState:UIControlStateNormal];
            }
        } else if ([self.delegate respondsToSelector:@selector(photoBrowserSelectedPhotoCount:)]) {
            NSUInteger selectedCount = [self.delegate photoBrowserSelectedPhotoCount:self];
            if (selectedCount == 0) {
                _doneButton.enabled = NO;
                [_doneButton setTitle:@"确定" forState:UIControlStateDisabled];
            } else {
                _doneButton.enabled = YES;
                title = [title stringByAppendingString:[NSString stringWithFormat:@"(%d)", (int)selectedCount]];
                [_doneButton setTitle:title forState:UIControlStateNormal];
            }
        } else if ([self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
            NSAssert(0, @"请实现 photoBrowserSelectedPhotoCount");
        } else {
            _doneButton.enabled = YES;
            [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}

- (void)configSubviews {
    _titleLabel.text = [NSString stringWithFormat:@"%d/%d", (int)_currentPageIndex + 1, (int)[self numberOfPhotos]];
//    _indexLabel.text = [NSString stringWithFormat:@"%d/%d", (int)_currentPageIndex + 1, (int)[self numberOfPhotos]];
//    CGSize indexSize = [_indexLabel sizeThatFits:CGSizeZero];
//    CGFloat width = ceil(indexSize.width);
//    _indexLabel.width = width;
    _cropButton.left = 14;
    _selectButton.selected = [self photoIsSelectedAtIndex:_currentPageIndex];
    if (_showCropButton == YES) {
        EJPhoto * photo = (EJPhoto *)[self photoAtIndex:_currentPageIndex];
        if (photo.isVideo && [photo.videoURL.absoluteString length] > 0) {// 网络视频
            _cropButton.hidden = YES;
        } else {
            _cropButton.hidden = NO;
        }
    }
}

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    
	// Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    
    // Update nav
//    [self updateNavigation];
    
    // Content offset
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
    
    // Status bar
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    
    // Update UI
	[self hideControlsAfterDelay];
    
    // If rotation occured while we're presenting a modal
    // and the index changed, make sure we show the right one now
    if (_currentPageIndex != _pageIndexBeforeRotation) {
        [self jumpToPageAtIndex:_pageIndexBeforeRotation animated:NO];
    }
    
    // Layout
    [self.view setNeedsLayout];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    
    // Autoplay if first is video
    if (!_viewHasAppearedInitially) {
        if (_autoPlayOnAppear) {
            id<EJPhoto> photo = [self photoAtIndex:_currentPageIndex];
            if ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo) {
                [self playVideoAtIndex:_currentPageIndex];
            }
        }
    }
    
    _viewHasAppearedInitially = YES;
        
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Detect if rotation occurs while we're presenting a modal
    _pageIndexBeforeRotation = _currentPageIndex;
    
    // Check that we're disappearing for good
    // self.isMovingFromParentViewController just doesn't work, ever. Or self.isBeingDismissed
    if ([self.navigationController.viewControllers objectAtIndex:0] != self && ![self.navigationController.viewControllers containsObject:self]) {

        // State
        _viewIsActive = NO;
        [self clearCurrentVideo]; // Clear current playing video
    }
    
    // Controls
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
	// Super
	[super viewWillDisappear:animated];
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent && _hasBelongedToViewController) {
        [NSException raise:@"EJPhotoBrowser Instance Reuse" format:@"EJPhotoBrowser instances cannot be reused."];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) _hasBelongedToViewController = YES;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutVisiblePages];
}

- (void)layoutVisiblePages {
    
	// Flag
	_performingLayout = YES;
	
	// Toolbar
//    _toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    
	// Remember index
	NSUInteger indexPriorToLayout = _currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
    if (!_skipNextPagingScrollViewPositioning) {
        _pagingScrollView.frame = pagingScrollViewFrame;
    }
    _skipNextPagingScrollViewPositioning = NO;
	
	// Recalculate contentSize based on current orientation
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (EJZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
		page.frame = [self frameForPageAtIndex:index];
//        if (page.captionView) {
//            page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
//        }
//        if (page.selectedButton) {
//            page.selectedButton.frame = [self frameForSelectedButton:page.selectedButton atIndex:index];
//        }
        if (page.playButton) {
            page.playButton.frame = [self frameForPlayButton:page.playButton atIndex:index];
        }
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }

	}
    
    // Adjust video loading indicator if it's visible
//    [self positionVideoLoadingIndicator];
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
	// Reset
	_currentPageIndex = indexPriorToLayout;
	_performingLayout = NO;
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
    }

    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%d/%d", (int)_currentPageIndex + 1, (int)numberOfPhotos];
//    CGSize indexSize = [_indexLabel sizeThatFits:CGSizeZero];
//    _indexLabel.width = ceil(indexSize.width);
    _cropButton.left = 14;
    _selectButton.selected = [self photoIsSelectedAtIndex:_currentPageIndex];
    [self configDoneButton];
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
    
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_fixedPhotosArray) {
            _photoCount = _fixedPhotosArray.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<EJPhoto>)photoAtIndex:(NSUInteger)index {
    id <EJPhoto> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            } else if (_fixedPhotosArray && index < _fixedPhotosArray.count) {
                photo = [_fixedPhotosArray objectAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (id<EJPhoto>)thumbPhotoAtIndex:(NSUInteger)index {
    id <EJPhoto> photo = nil;
    if (index < _thumbPhotos.count) {
        if ([_thumbPhotos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)]) {
                photo = [_delegate photoBrowser:self thumbPhotoAtIndex:index];
            }
            if (photo) [_thumbPhotos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_thumbPhotos objectAtIndex:index];
        }
    }
    return photo;
}

//- (EJCaptionView *)captionViewForPhotoAtIndex:(NSUInteger)index {
//    EJCaptionView *captionView = nil;
//    if ([_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
//        captionView = [_delegate photoBrowser:self captionViewForPhotoAtIndex:index];
//    } else {
//        id <EJPhoto> photo = [self photoAtIndex:index];
//        if ([photo respondsToSelector:@selector(caption)]) {
//            if ([photo caption]) captionView = [[EJCaptionView alloc] initWithPhoto:photo];
//        }
//    }
//    captionView.alpha = [self areControlsHidden] ? 0 : 1; // Initial alpha
//    return captionView;
//}

- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index {
    BOOL value = NO;
    if (_showSelectButton) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:)]) {
            value = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:index];
        }
    }
    return value;
}

- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index {
    if (_showSelectButton) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
            [self.delegate photoBrowser:self photoAtIndex:index selectedChanged:selected];
        }
    }
}

- (UIImage *)imageForPhoto:(id<EJPhoto>)photo {
	if (photo) {
		// Get image or obtain in background
		if ([photo underlyingImage]) {
			return [photo underlyingImage];
		} else {
            [photo loadUnderlyingImageAndNotify];
		}
	}
	return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<EJPhoto>)photo {
    EJZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <EJPhoto> photoAtIndex = [self photoAtIndex:pageIndex-1];
                if (![photoAtIndex underlyingImage]) {
                    [photoAtIndex loadUnderlyingImageAndNotify];
                    EJLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <EJPhoto> photoAtIndex = [self photoAtIndex:pageIndex+1];
                if (![photoAtIndex underlyingImage]) {
                    [photoAtIndex loadUnderlyingImageAndNotify];
                    EJLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - EJPhoto Loading Notification

- (void)handleEJPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <EJPhoto> photo = [notification object];
    EJZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            
            // Failed to load
            [page displayImageFailure];
        }
        // Update nav
//        [self updateNavigation];
    }
}

#pragma mark - Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
	
	// Recycle no longer needed pages
    NSInteger pageIndex;
	for (EJZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
			[_recycledPages addObject:page];
//            [page.captionView removeFromSuperview];
//            [page.selectedButton removeFromSuperview];
            [page.playButton removeFromSuperview];
            [page prepareForReuse];
			[page removeFromSuperview];
			EJLog(@"Removed page at index %lu", (unsigned long)pageIndex);
		}
	}
	[_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
			EJZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[EJZoomingScrollView alloc] initWithPhotoBrowser:self];
			}
			[_visiblePages addObject:page];
			[self configurePage:page forIndex:index];

			[_pagingScrollView addSubview:page];
			EJLog(@"Added page at index %lu", (unsigned long)index);
            
            // Add caption
//            EJCaptionView *captionView = [self captionViewForPhotoAtIndex:index];
//            if (captionView) {
//                captionView.frame = [self frameForCaptionView:captionView atIndex:index];
//                [_pagingScrollView addSubview:captionView];
//                page.captionView = captionView;
//            }
            
            // Add play button if needed
            if (page.displayingVideo) {
                UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [playButton setImage:[UIImage imageNamed:@"ejtools_play"] forState:UIControlStateNormal];
                [playButton setImage:[UIImage imageNamed:@"ejtools_play"] forState:UIControlStateHighlighted];
                [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [playButton sizeToFit];
                playButton.frame = [self frameForPlayButton:playButton atIndex:index];
                [_pagingScrollView addSubview:playButton];
                page.playButton = playButton;
            }
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (EJZoomingScrollView *page in _visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (EJZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	EJZoomingScrollView *thePage = nil;
	for (EJZoomingScrollView *page in _visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (EJZoomingScrollView *)pageDisplayingPhoto:(id<EJPhoto>)photo {
	EJZoomingScrollView *thePage = nil;
	for (EJZoomingScrollView *page in _visiblePages) {
		if (page.photo == photo || page.thumb == photo) {
			thePage = page;
            break;
		}
	}
	return thePage;
}

- (void)configurePage:(EJZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    id<EJPhoto> photo = [self photoAtIndex:index];
    id<EJPhoto> thumb = [self thumbPhotoAtIndex:index];
    [page configPhoto:photo thumb:thumb];
}

- (EJZoomingScrollView *)dequeueRecycledPage {
	EJZoomingScrollView *page = [_recycledPages anyObject];
	if (page) {
		[_recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    // Handle 0 photos
    if (![self numberOfPhotos]) {
        // Show controls
        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Handle video on page change
    if (index != _currentVideoIndex) {
        [self clearCurrentVideo];
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) { 
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                EJLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                EJLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <EJPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
//    [self updateNavigation];
    
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    frame.size.height -= (kToolsStatusHeight + kToolsBottomSafeHeight);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
	return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

//- (CGRect)frameForCaptionView:(EJCaptionView *)captionView atIndex:(NSUInteger)index {
//    CGRect pageFrame = [self frameForPageAtIndex:index];
//    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
//    CGRect captionFrame = CGRectMake(pageFrame.origin.x,
//                                     pageFrame.size.height - captionSize.height/* - (_toolbar.superview?_toolbar.frame.size.height:0)*/,
//                                     pageFrame.size.width,
//                                     captionSize.height);
//    return CGRectIntegral(captionFrame);
//}

- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGFloat padding = 20;
    CGFloat yOffset = 0;
    if (![self areControlsHidden]) {
        yOffset = CGRectGetMaxY(_navigationBar.frame);
    }
    CGRect selectedButtonFrame = CGRectMake(pageFrame.origin.x + pageFrame.size.width - selectedButton.frame.size.width - padding,
                                            padding + yOffset,
                                            selectedButton.frame.size.width,
                                            selectedButton.frame.size.height);
    return CGRectIntegral(selectedButtonFrame);
}

- (CGRect)frameForPlayButton:(UIButton *)playButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
//    return CGRectMake(floorf(CGRectGetMidX(pageFrame) - playButton.frame.size.width / 2),
//                      floorf(CGRectGetMidY(pageFrame) - playButton.frame.size.height / 2),
//                      playButton.frame.size.width,
//                      playButton.frame.size.height);
    return pageFrame;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
    // Checks
	if (!_viewIsActive || _performingLayout)
        return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
    
    [self configSubviews];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
//    [self updateNavigation];
}

#pragma mark - Navigation

//- (void)updateNavigation {
//
//    // Title
//    NSUInteger numberOfPhotos = [self numberOfPhotos];
//    if (numberOfPhotos > 1) {
//        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
//            self.title = [_delegate photoBrowser:self titleForPhotoAtIndex:_currentPageIndex];
//        } else {
//            self.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
//        }
//    } else {
//        self.title = nil;
//    }

	// Buttons
//    _previousButton.enabled = (_currentPageIndex > 0);
//    _nextButton.enabled = (_currentPageIndex < numberOfPhotos - 1);
    
    // Disable action button if there is no image or it's a video
//    id<EJPhoto> photo = [self photoAtIndex:_currentPageIndex];
//    if ([photo underlyingImage] == nil || ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo)) {
//        _actionButton.enabled = NO;
//        _actionButton.tintColor = [UIColor clearColor]; // Tint to hide button
//    } else {
//        _actionButton.enabled = YES;
//        _actionButton.tintColor = nil;
//    }
	
//}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
	
	// Change page
	if (index < [self numberOfPhotos]) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
//        [self updateNavigation];
    }
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage {
    [self showPreviousPhotoAnimated:NO];
}
- (void)gotoNextPage {
    [self showNextPhotoAnimated:NO];
}

- (void)showPreviousPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex-1 animated:animated];
}

- (void)showNextPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex+1 animated:animated];
}

#pragma mark - Interactions

- (void)selectedButtonTapped:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    selectedButton.selected = !selectedButton.selected;
    NSUInteger index = NSUIntegerMax;
    if (index != NSUIntegerMax) {
        [self setPhotoSelected:selectedButton.selected atIndex:index];
    }
}

- (void)playButtonTapped:(id)sender {
    // Ignore if we're already playing a video
    NSUInteger index = [self indexForPlayButton:sender];
    if (index != NSUIntegerMax) {
        [self playVideoAtIndex:index];
    }
}

- (NSUInteger)indexForPlayButton:(UIView *)playButton {
    NSUInteger index = NSUIntegerMax;
    for (EJZoomingScrollView *page in _visiblePages) {
        if (page.playButton == playButton) {
            index = page.index;
            break;
        }
    }
    return index;
}

#pragma mark - EJVideoPlayerDelegate
- (void)ej_videoPlayerDidClickEdit:(EJVideoPlayerVC *)videoPlayer {
    [videoPlayer dismissViewControllerAnimated:NO completion:^{
        EJPhoto * photo = (EJPhoto *)[self photoAtIndex:_currentPageIndex];
        if (photo.asset) {
            LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:photo.asset defaultDuration:_maxVideoDuration];
            vc.delegate = self;
            [self ej_presentViewController:vc animated:YES completion:nil];
        }
    }];
}

#pragma mark - LSInterceptVideoDelegate
- (void)ls_interceptVideoDidCropVideo:(NSString *)assetLocalId {
    if ([assetLocalId length] == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didCropPhotoAtIndex:assetId:)]) {
        [self.delegate photoBrowser:self didCropPhotoAtIndex:_currentPageIndex assetId:assetLocalId];
    }
}

#pragma mark - Video
- (void)playVideoAtIndex:(NSUInteger)index {
    id photo = [self photoAtIndex:index];
    if ([photo respondsToSelector:@selector(getVideoURL:)]) {
        
        // Valid for playing
        [self clearCurrentVideo];
        _currentVideoIndex = index;
//        [self setVideoLoadingIndicatorVisible:YES atPageIndex:index];

        // Get video and play
        typeof(self) __weak weakSelf = self;
        [photo getVideoURL:^(NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // If the video is not playing anymore then bail
                typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;
                if (strongSelf->_currentVideoIndex != index || !strongSelf->_viewIsActive) {
                    return;
                }
                if (url) {
                    [weakSelf _playVideo:url atPhotoIndex:index];
                } else {
//                    [weakSelf setVideoLoadingIndicatorVisible:NO atPageIndex:index];
                }
            });
        }];
        
    }
}

- (void)_playVideo:(NSURL *)videoURL atPhotoIndex:(NSUInteger)index {
    EJVideoPlayerVC * vc = [[EJVideoPlayerVC alloc] initWithURL:videoURL.absoluteString];
    vc.delegate = self;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self ej_presentViewController:vc animated:YES completion:nil];
}

- (void)clearCurrentVideo {
    [[self pageDisplayedAtIndex:_currentVideoIndex] playButton].hidden = NO;
    _currentVideoIndex = NSUIntegerMax;
}

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Force visible
    if (![self numberOfPhotos] || _alwaysShowControl)
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
//    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    
    // Toolbar, nav bar and captions
    // Pre-appear animation positions for sliding
    if ([self areControlsHidden] && !hidden && animated) {
        
        // Toolbar
//        _toolbar.frame = CGRectOffset([self frameForToolbarAtOrientation:self.interfaceOrientation], 0, animatonOffset);
        
        // Captions
//        for (EJZoomingScrollView *page in _visiblePages) {
//            if (page.captionView) {
//                EJCaptionView *v = page.captionView;
//                // Pass any index, all we're interested in is the Y
//                CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
//                captionFrame.origin.x = v.frame.origin.x; // Reset X
//                v.frame = CGRectOffset(captionFrame, 0, animatonOffset);
//            }
//        }
        
    }
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
//        CGFloat alpha = hidden ? 0 : 1;

        // Captions
//        for (EJZoomingScrollView *page in _visiblePages) {
//            if (page.captionView) {
//                EJCaptionView *v = page.captionView;
//                // Pass any index, all we're interested in is the Y
//                CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
//                captionFrame.origin.x = v.frame.origin.x; // Reset X
//                if (hidden) captionFrame = CGRectOffset(captionFrame, 0, animatonOffset);
//                v.frame = captionFrame;
//                v.alpha = alpha;
//            }
//        }
        _navigationBar.hidden = hidden;
        _bottomBar.hidden = hidden;

    } completion:^(BOOL finished) {}];
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	if (!permanent) [self hideControlsAfterDelay];
	
}

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return [self presentingViewControllerPrefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (_controlVisibilityTimer) {
		[_controlVisibilityTimer invalidate];
		_controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	if (![self areControlsHidden]) {
        [self cancelControlHiding];
		_controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayToHideElements target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (BOOL)areControlsHidden { return (_navigationBar.hidden); }
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)showControls { [self setControlsHidden:NO animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

#pragma mark - Properties

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    // Validate
    NSUInteger photoCount = [self numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [self numberOfPhotos]-1;
    }
    _currentPageIndex = index;
	if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index animated:NO];
        if (!_viewIsActive)
            [self tilePages]; // Force tiling if view is not visible
    }
}

//#pragma mark - Misc

//- (void)doneButtonPressed:(id)sender {
    // Only if we're modal and there's a done button
//    if (_doneButton) {
//        // See if we actually just want to show/hide grid
//        if (self.enableGrid) {
//            if (self.startOnGrid && !_gridController) {
//                [self showGrid:YES];
//                return;
//            } else if (!self.startOnGrid && _gridController) {
//                [self hideGrid];
//                return;
//            }
//        }
//        // Dismiss view controller
//        if ([_delegate respondsToSelector:@selector(photoBrowserDidFinishModalPresentation:)]) {
//            // Call delegate method and let them dismiss us
//            [_delegate photoBrowserDidFinishModalPresentation:self];
//        } else  {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//    }
//}

#pragma mark - Actions
- (void)handleClickBackItem {
    if ([self.delegate respondsToSelector:@selector(photoBrowserDidCancel:)]) {
        [self.delegate photoBrowserDidCancel:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickDoneButton {
    if ([self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
        NSUInteger maxCount = [self.delegate photoBrowserMaxSelectePhotoCount:self];
        if (maxCount == 1) {
            if (_showCropButton) {
                BOOL needCrop = NO;
                EJPhoto * photo = (EJPhoto *)[self photoAtIndex:_currentPageIndex];
                if (photo.asset) {//本地资源
                    if (photo.isVideo) {
                        needCrop = photo.asset.duration > _maxVideoDuration;
                    } else {
                        CGFloat cropScale = 0;
                        if ([self.delegate respondsToSelector:@selector(photoBrowser:crapScaleAtIndex:)]) {
                            cropScale = [self.delegate photoBrowser:self crapScaleAtIndex:_currentPageIndex];
                        }
                        if (cropScale != 0) {
                            needCrop = photo.asset.pixelWidth * 1.0 / photo.asset.pixelHeight != cropScale;
                        }
                    }
                }
                if (_forcedCrop) {
                    [self handleClickCropButton];
                    return;
                } else {
                    if (needCrop) {
                        // 弹框提醒裁剪
                        NSString * msg;
                        if (photo.isVideo) {
                            msg = @"所选视频超出限定时长，请裁剪编辑后再上传？";
                        } else {
                            msg = @"比例不合适，请裁剪编辑后再上传？";
                        }
                        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self handleClickCropButton];
                        }];
                        [alertC addAction:cancelAction];
                        [alertC addAction:doneAction];
                        [self presentViewController:alertC animated:YES completion:nil];
                        return;
                    }
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
                    [self.delegate photoBrowser:self photoAtIndex:_currentPageIndex selectedChanged:YES];
                }
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowserDidFinish:)]) {
        [self.delegate photoBrowserDidFinish:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleClickCropButton {
    EJPhoto * photo = (EJPhoto *)[self photoAtIndex:_currentPageIndex];
    if (photo.asset) {// 本地资源
        PHAsset * asset = photo.asset;
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            // 视频裁剪
            LSInterceptVideo * vc = [[LSInterceptVideo alloc] initWithAsset:asset defaultDuration:_maxVideoDuration];
            vc.delegate = self;
            [self ej_presentViewController:vc animated:YES completion:nil];
            return;
        }
        if (asset.mediaType == PHAssetMediaTypeImage) {
            // 图片裁剪
            PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            options.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage * image = [UIImage imageWithData:imageData];
                EJImageCropperVC * vc = [[EJImageCropperVC alloc] initWithImage:image];
                CGFloat cropScale = 0;
                if ([self.delegate respondsToSelector:@selector(photoBrowser:crapScaleAtIndex:)]) {
                    cropScale = [self.delegate photoBrowser:self crapScaleAtIndex:_currentPageIndex];
                }
                vc.cropScale = cropScale;
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            return;
        }
        return;
    }
    // 网络资源
    if (photo.isVideo) {
        // 网络视频不裁剪
        return;
    } else {
        UIImage * image = [UIImage imageWithUrlString:photo.photoURL.absoluteString];
        EJImageCropperVC * vc = [[EJImageCropperVC alloc] initWithImage:image];
        CGFloat cropScale = 0;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:crapScaleAtIndex:)]) {
            cropScale = [self.delegate photoBrowser:self crapScaleAtIndex:_currentPageIndex];
        }
        vc.cropScale = cropScale;
        vc.delegate = self;
//        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (void)handleClickSelectButton {
    BOOL isCanSelect = YES;
    if (_selectButton.isSelected == NO) {
        if ([self.delegate respondsToSelector:@selector(photoBrowserCanPhotoSelectedAtIndex:)]) {
            isCanSelect = [self.delegate photoBrowserCanPhotoSelectedAtIndex:self];
        }
    }
    if (isCanSelect == NO) {
        NSUInteger selectedCount = [self.delegate photoBrowserSelectedPhotoCount:self];
        [EJProgressHUD showAlert:[NSString stringWithFormat:@"最多只能选择%d个照片或视频", (int)selectedCount] forView:self.view];
        return;
    } else {
        EJPhoto * photo = (EJPhoto *)[self photoAtIndex:_currentPageIndex];
        if (photo.isVideo && photo.asset) {// 本地视频
            if (photo.asset.duration > _maxVideoDuration) {
                [EJProgressHUD showAlert:[NSString stringWithFormat:@"只能选择%d秒以内的视频", (int)_maxVideoDuration] forView:self.view];
                return;
            }
        }
    }
    _selectButton.selected = !_selectButton.isSelected;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
        [self.delegate photoBrowser:self photoAtIndex:_currentPageIndex selectedChanged:_selectButton.isSelected];
    }
    [self configDoneButton];
    if (self.numberOfPhotos == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - EJImageCropperDelegate
- (void)ej_imageCropperVCDidCancel {
    
}

- (void)ej_imageCropperVCDidCrop:(UIImage *)image {
    [self.progressHUD showAnimated:YES];
    [[LSSaveToAlbum mainSave] saveImage:image successBlock:^(NSString *assetLocalId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progressHUD hideAnimated:YES];
            if ([assetLocalId length] > 0) {
                if ([self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
                    NSUInteger maxCount = [self.delegate photoBrowserMaxSelectePhotoCount:self];
                    if (maxCount == 1) {
                        if ([self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:)]) {
                            BOOL isSelected = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:_currentPageIndex];
                            if (!isSelected) {
                                if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
                                    [self.delegate photoBrowser:self photoAtIndex:_currentPageIndex selectedChanged:YES];
                                }
                            }
                        } else {
                            NSAssert(0, @"please configure photoBrowser:isPhotoSelectedAtIndex:");
                        }
                    } else {
                        // 获取当前的预选状态
                        BOOL isSelected = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:_currentPageIndex];
                        if (isSelected == NO && [self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:selectedChanged:)]) {
                            [self.delegate photoBrowser:self photoAtIndex:_currentPageIndex selectedChanged:YES];
                        }
                    }
                }
                if ([self.delegate respondsToSelector:@selector(photoBrowser:didCropPhotoAtIndex:assetId:)]) {
                    [self.delegate photoBrowser:self didCropPhotoAtIndex:_currentPageIndex assetId:assetLocalId];
                }
                if ([self.delegate respondsToSelector:@selector(photoBrowserMaxSelectePhotoCount:)]) {
                    NSUInteger maxCount = [self.delegate photoBrowserMaxSelectePhotoCount:self];
                    if (maxCount == 1) {
                        if ([self.delegate respondsToSelector:@selector(photoBrowserDidFinish:)]) {
                            [self.delegate photoBrowserDidFinish:self];
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        });
    }];
}

#pragma mark - Action Progress

- (EJProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[EJProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

@end
