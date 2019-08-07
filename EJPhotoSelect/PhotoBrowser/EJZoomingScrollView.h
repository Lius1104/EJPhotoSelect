//
//  ZoomingScrollView.h
//  EJPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EJPhotoProtocol.h"
#import "EJTapDetectingImageView.h"
#import "EJTapDetectingView.h"

@class EJPhotoBrowser, EJPhoto;//, EJCaptionView;

@interface EJZoomingScrollView : UIScrollView <UIScrollViewDelegate, EJTapDetectingImageViewDelegate, EJTapDetectingViewDelegate> {

}

@property () NSUInteger index;
@property (nonatomic) id <EJPhoto> photo;
@property (nonatomic) id <EJPhoto> thumb;
//@property (nonatomic, weak) EJCaptionView *captionView;
@property (nonatomic, weak) UIButton *playButton;

- (id)initWithPhotoBrowser:(EJPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

- (void)configPhoto:(id<EJPhoto>)photo thumb:(id<EJPhoto>)thumb;

@end
