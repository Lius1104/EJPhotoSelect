//
//  EJPhotoBrowser_Private.h
//  EJPhotoBrowser
//
//  Created by Michael Waterfall on 08/10/2013.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EJZoomingScrollView.h"

// Declare private methods of browser
@interface EJPhotoBrowser () {
    
	// Data
    NSUInteger _photoCount;
    NSMutableArray *_photos;
    NSMutableArray *_thumbPhotos;
	NSArray *_fixedPhotosArray; // Provided via init
	
	// Views
	UIScrollView *_pagingScrollView;
	
	// Paging & layout
	NSMutableSet *_visiblePages, *_recycledPages;
	NSUInteger _currentPageIndex;
    NSUInteger _previousPageIndex;
    CGRect _previousLayoutBounds;
	NSUInteger _pageIndexBeforeRotation;
	
	// Navigation & controls
//    UIToolbar *_toolbar;
    
    UIView * _navigationBar;
    UIButton * _backItem;// 返回按钮
    UILabel * _titleLabel;// 标题
    UIButton * _doneButton;// 确定按钮
    
    UIView * _bottomBar;//底部 工具栏
//    UILabel * _indexLabel;// 索引
    UIButton * _cropButton;// 裁剪按钮
    UIButton * _selectButton;// 选择按钮
    
//	NSTimer *_controlVisibilityTimer;
//    UIBarButtonItem *_previousButton, *_nextButton, *_actionButton, *_doneButton;
//    EJProgressHUD *_progressHUD;
    
    // Grid
//    EJGridViewController *_gridController;
//    UIBarButtonItem *_gridPreviousLeftNavItem;
//    UIBarButtonItem *_gridPreviousRightNavItem;
    
    // Appearance
    BOOL _previousNavBarHidden;
    BOOL _previousNavBarTranslucent;
    UIBarStyle _previousNavBarStyle;
    UIStatusBarStyle _previousStatusBarStyle;
    UIColor *_previousNavBarTintColor;
    UIColor *_previousNavBarBarTintColor;
    UIBarButtonItem *_previousViewControllerBackButton;
    UIImage *_previousNavigationBarBackgroundImageDefault;
    UIImage *_previousNavigationBarBackgroundImageLandscapePhone;
    
    // Video
//    MPMoviePlayerViewController *_currentVideoPlayerViewController;
    NSUInteger _currentVideoIndex;
//    UIActivityIndicatorView *_currentVideoLoadingIndicator;
    
    // Misc
    BOOL _hasBelongedToViewController;
    BOOL _isVCBasedStatusBarAppearance;
    BOOL _statusBarShouldBeHidden;
    BOOL _displayActionButton;
    BOOL _leaveStatusBarAlone;
	BOOL _performingLayout;
//    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _didSavePreviousStateOfNavBar;
    BOOL _skipNextPagingScrollViewPositioning;
    BOOL _viewHasAppearedInitially;
    
}

// Properties
@property (nonatomic) UIActivityViewController *activityViewController;

// Layout
- (void)layoutVisiblePages;
- (void)performLayout;
- (BOOL)presentingViewControllerPrefersStatusBarHidden;

// Nav Bar Appearance
//- (void)setNavBarAppearance:(BOOL)animated;
//- (void)storePreviousNavBarAppearance;
//- (void)restorePreviousNavBarAppearance:(BOOL)animated;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (EJZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (EJZoomingScrollView *)pageDisplayingPhoto:(id<EJPhoto>)photo;
- (EJZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(EJZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;
//- (CGRect)frameForCaptionView:(EJCaptionView *)captionView atIndex:(NSUInteger)index;
- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index;

// Navigation
//- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Grid
//- (void)showGrid:(BOOL)animated;
//- (void)hideGrid;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

// Data
- (NSUInteger)numberOfPhotos;
- (id<EJPhoto>)photoAtIndex:(NSUInteger)index;
- (id<EJPhoto>)thumbPhotoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<EJPhoto>)photo;
- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index;
- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index;
- (void)loadAdjacentPhotosIfNecessary:(id<EJPhoto>)photo;
- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

@end

