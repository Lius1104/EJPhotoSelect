//
//  JPImageresizerFrameView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerTypedef.h"

@interface JPImageresizerFrameView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  contentSize:(CGSize)contentSize
                    frameType:(JPImageresizerFrameType)frameType
               animationCurve:(JPAnimationCurve)animationCurve
                   blurEffect:(UIBlurEffect *)blurEffect
                      bgColor:(UIColor *)bgColor
                    maskAlpha:(CGFloat)maskAlpha
                  strokeColor:(UIColor *)strokeColor
                verBaseMargin:(CGFloat)verBaseMargin
                horBaseMargin:(CGFloat)horBaseMargin
                resizeWHScale:(CGFloat)resizeWHScale
                   scrollView:(UIScrollView *)scrollView
                    imageView:(UIImageView *)imageView
                  borderImage:(UIImage *)borderImage
         borderImageRectInset:(CGPoint)borderImageRectInset
                isRoundResize:(BOOL)isRoundResize
                isShowMidDots:(BOOL)isShowMidDots
    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

@property (nonatomic, weak, readonly) UIPanGestureRecognizer *panGR;

@property (nonatomic, assign, readonly) JPImageresizerFrameType frameType;

@property (nonatomic, assign, readonly) NSTimeInterval defaultDuration;

@property (nonatomic, assign) JPAnimationCurve animationCurve;

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) UIBlurEffect *blurEffect;
@property (nonatomic) UIColor *bgColor;
@property (nonatomic) CGFloat maskAlpha;
- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated;

@property (nonatomic, assign, readonly) CGRect imageresizerFrame;

@property (nonatomic, assign) CGFloat resizeWHScale;
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

- (void)roundResize:(BOOL)isAnimated;
- (BOOL)isRoundResizing;

@property (nonatomic, assign) BOOL isPreview;
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

@property (nonatomic, assign) CGFloat initialResizeWHScale;

@property (nonatomic, assign) BOOL edgeLineIsEnabled;

@property (nonatomic, assign, readonly) BOOL isCanRecovery;
@property (nonatomic, copy) JPImageresizerIsCanRecoveryBlock imageresizerIsCanRecovery;

@property (nonatomic, assign, readonly) BOOL isPrepareToScale;
@property (nonatomic, copy) JPImageresizerIsPrepareToScaleBlock imageresizerIsPrepareToScale;

@property (nonatomic, assign, readonly) JPImageresizerRotationDirection rotationDirection;

@property (nonatomic, assign, readonly) CGFloat scrollViewMinZoomScale;

@property (nonatomic, strong) UIImage *borderImage;
@property (nonatomic, assign) CGPoint borderImageRectInset;

@property (nonatomic, assign) BOOL isShowMidDots;

@property (nonatomic, copy) BOOL (^isVerticalityMirror)(void);
@property (nonatomic, copy) BOOL (^isHorizontalMirror)(void);

- (void)updateFrameType:(JPImageresizerFrameType)frameType;

- (void)updateImageresizerFrameWithVerBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin duration:(NSTimeInterval)duration;;

- (void)startImageresizer;
- (void)endedImageresizer;

- (void)rotationWithDirection:(JPImageresizerRotationDirection)direction rotationDuration:(NSTimeInterval)rotationDuration;

- (void)willRecoveryToRoundResize;
- (void)willRecoveryByResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;
- (void)recoveryWithDuration:(NSTimeInterval)duration;
- (void)recoveryDone;

- (void)willMirror:(BOOL)animated;
- (void)verticalityMirrorWithDiffX:(CGFloat)diffX;
- (void)horizontalMirrorWithDiffY:(CGFloat)diffY;
- (void)mirrorDone;

- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete compressScale:(CGFloat)compressScale;

@end

@interface JPImageresizerProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic, weak) id target;
@end
