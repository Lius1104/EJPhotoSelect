//
//  JPImageresizerFrameView.m
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/11.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import "JPImageresizerFrameView.h"
#import "JPImageresizerBlurView.h"
#import "UIImage+JPImageresizer.h"
#import "CALayer+JPImageresizer.h"

typedef NS_ENUM(NSUInteger, JPDotRegion) {
    JPDR_Center,
    JPDR_LeftTop,
    JPDR_LeftMid,
    JPDR_LeftBottom,
    JPDR_RightTop,
    JPDR_RightMid,
    JPDR_RightBottom,
    JPDR_TopMid,
    JPDR_BottomMid
};

typedef NS_ENUM(NSUInteger, JPInsideLinePosition) {
    JPILP_HorTop,
    JPILP_HorBottom,
    JPILP_VerLeft,
    JPILP_VerRight
};

@interface JPImageresizerFrameView ()
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) JPImageresizerBlurView *blurView;
@property (nonatomic, weak) UIImageView *borderImageView;
- (CGRect)borderImageViewFrame;

// 遮罩图层
@property (nonatomic, weak) CAShapeLayer *maskLayer;
// 线框
@property (nonatomic, weak) CAShapeLayer *frameLayer;
// 左上中下点
@property (nonatomic, weak) CAShapeLayer *leftTopDot;
@property (nonatomic, weak) CAShapeLayer *leftMidDot;
@property (nonatomic, weak) CAShapeLayer *leftBottomDot;
// 右上中下点
@property (nonatomic, weak) CAShapeLayer *rightTopDot;
@property (nonatomic, weak) CAShapeLayer *rightMidDot;
@property (nonatomic, weak) CAShapeLayer *rightBottomDot;
// 上中点
@property (nonatomic, weak) CAShapeLayer *topMidDot;
// 下中点
@property (nonatomic, weak) CAShapeLayer *bottomMidDot;
// 网格线
@property (nonatomic, weak) CAShapeLayer *horTopLine;
@property (nonatomic, weak) CAShapeLayer *horBottomLine;
@property (nonatomic, weak) CAShapeLayer *verLeftLine;
@property (nonatomic, weak) CAShapeLayer *verRightLine;

@property (nonatomic, assign) CGRect originImageFrame;
@property (nonatomic, assign) CGRect maxResizeFrame;
- (CGFloat)maxResizeX;
- (CGFloat)maxResizeY;
- (CGFloat)maxResizeW;
- (CGFloat)maxResizeH;

@property (nonatomic) CGFloat imageresizeX;
@property (nonatomic) CGFloat imageresizeY;
@property (nonatomic) CGFloat imageresizeW;
@property (nonatomic) CGFloat imageresizeH;
- (CGSize)imageresizerSize;
- (CGSize)imageViewSzie;
@end

@implementation JPImageresizerFrameView
{
    CGFloat _frameLayerLineW;
    
    CGFloat _dotWH;
    CGFloat _halfDotWH;
    
    CGFloat _arrLineW;
    CGFloat _halfArrLineW;
    CGFloat _arrLength;
    CGFloat _midArrLength;
    
    CGFloat _scopeWH;
    CGFloat _halfScopeWH;
    
    CGFloat _minImageWH;
    CGFloat _baseImageW;
    CGFloat _baseImageH;
    CGFloat _startResizeW;
    CGFloat _startResizeH;
    CGFloat _originWHScale;
    CGFloat _verBaseMargin;
    CGFloat _horBaseMargin;
    CGFloat _diffHalfW;
    CGFloat _diffRotLength; // 扩大遮罩的区域（防止旋转时有空白区域）
    CGSize _contentSize;
    
    BOOL _isHideFrameLine;
    BOOL _isArbitrarily;
    BOOL _isToBeArbitrarily;
    
    NSString *_kCAMediaTimingFunction;
    UIViewAnimationOptions _animationOption;
    NSTimeInterval _defaultDuration;
    NSTimeInterval _blurDuration;
    
    JPDotRegion _currDR;
    CGPoint _diagonal;
    
    BOOL _isRound;
}

#pragma mark - setter

- (void)setOriginImageFrame:(CGRect)originImageFrame {
    _originImageFrame = originImageFrame;
    _originWHScale = originImageFrame.size.width / originImageFrame.size.height;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self updateShapeLayersStrokeColor];
}

- (void)setBlurEffect:(UIBlurEffect *)blurEffect {
    [self.blurView setBlurEffect:blurEffect duration:0];
}

- (void)setBgColor:(UIColor *)bgColor {
    [self.blurView setBgColor:bgColor duration:0];
    self.superview.layer.backgroundColor = bgColor.CGColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha {
    [self.blurView setMaskAlpha:maskAlpha duration:0];
}

- (void)setImageresizerFrame:(CGRect)imageresizerFrame {
    [self updateImageresizerFrame:imageresizerFrame animateDuration:-1.0];
}

- (void)setImageresizeX:(CGFloat)imageresizeX {
    _imageresizerFrame.origin.x = imageresizeX;
}

- (void)setImageresizeY:(CGFloat)imageresizeY {
    _imageresizerFrame.origin.y = imageresizeY;
}

- (void)setImageresizeW:(CGFloat)imageresizeW {
    _imageresizerFrame.size.width = imageresizeW;
}

- (void)setImageresizeH:(CGFloat)imageresizeH {
    _imageresizerFrame.size.height = imageresizeH;
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale {
    [self setResizeWHScale:resizeWHScale isToBeArbitrarily:NO animated:NO];
}

- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated {
    if (_isRound) {
        [self setIsRound:NO animated:isAnimated];
        _resizeWHScale += 1;
    }
    if (resizeWHScale > 0 && [self isHorizontalDirection:_rotationDirection]) resizeWHScale = 1.0 / resizeWHScale;
    if (_resizeWHScale == resizeWHScale && !isToBeArbitrarily) return;
    _resizeWHScale = resizeWHScale;
    _isArbitrarily = resizeWHScale <= 0;
    _isToBeArbitrarily = isToBeArbitrarily;
    if (self.superview) {
        CGRect adjustResizeFrame = [self adjustResizeFrame];
        NSTimeInterval duration = isAnimated ? _defaultDuration : -1.0;
        _imageresizerFrame = adjustResizeFrame;
        [self adjustImageresizerFrame:adjustResizeFrame isAdvanceUpdateOffset:NO animateDuration:duration];
    }
}

- (void)roundResize:(BOOL)isAnimated {
    if (_isRound) return;
    [self setIsRound:YES animated:isAnimated];
    _resizeWHScale = 1;
    _isArbitrarily = NO;
    _isToBeArbitrarily = NO;
    if (self.superview) {
        CGRect adjustResizeFrame = [self adjustResizeFrame];
        _imageresizerFrame = adjustResizeFrame;
        [self adjustImageresizerFrame:adjustResizeFrame isAdvanceUpdateOffset:NO animateDuration:_defaultDuration];
    }
}

- (void)setIsRound:(BOOL)isRound animated:(BOOL)isAnimated {
    _isRound = isRound;
    
    if (isRound) {
        _frameLayerLineW = 1.5;
        _dotWH =  0.0;
        _halfDotWH = 0.0;
        _halfArrLineW = 0.0;
        _arrLength = 0.0;
        _midArrLength = 0.0;
    } else {
        _frameLayerLineW = _borderImage ? 0.0 : 1.0;
        _dotWH =  12.0;
        _halfDotWH = _dotWH * 0.5;
        _halfArrLineW = _arrLineW * 0.5;
        _arrLength = 20.0;
        _midArrLength = _arrLength * 0.85;
    }
    
    if (_borderImage) {
        CGFloat alpha = (isRound || _isPreview) ? 0 : 1;
        CGFloat lineWidth = _frameLayerLineW;
        void (^animations)(void) = ^{
            self.borderImageView.alpha = alpha;
            self.frameLayer.lineWidth = lineWidth;
        };
        if (isAnimated) {
            [UIView animateWithDuration:_defaultDuration delay:0 options:_animationOption animations:animations completion:nil];
        } else {
            animations();
        }
    } else {
        self.frameLayer.lineWidth = _frameLayerLineW;
        [self updateAllLayersOpacity];
    }
}

- (BOOL)isRoundResizing {
    return _isRound;
}

- (void)setIsPreview:(BOOL)isPreview {
    [self setIsPreview:isPreview animated:NO];
}

- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated {
    _isPreview = isPreview;
    self.userInteractionEnabled = !isPreview;
    
    CGFloat opacity = _isPreview ? 0 : 1;
    CGFloat otherOpacity = _isRound ? 0 : opacity;
    CGFloat midDotOpacity = (_isShowMidDots && !_isRound) ? opacity : 0.0;
    
    if (isAnimated) {
        NSTimeInterval duration = _defaultDuration;
        CAMediaTimingFunctionName timingFunctionName = _kCAMediaTimingFunction;
        [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
            [self.blurView setIsMaskAlpha:!isPreview duration:0];
        } completion:nil];
        if (_borderImage) {
            BOOL isRound = _isRound;
            [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
                self.borderImageView.alpha = isRound ? 0 : opacity;
                self.frameLayer.opacity = isRound ? opacity : 0;
            } completion:nil];
        } else {
            void (^layerOpacityAnimate)(CALayer *layer, id toValue) = ^(CALayer *layer, id toValue) {
                if (!layer) return;
                [layer jpir_addBackwardsAnimationWithKeyPath:@"opacity" fromValue:@(layer.opacity) toValue:toValue timingFunctionName:timingFunctionName duration:duration];
            };
            
            id toOpacity = @(opacity);
            layerOpacityAnimate(_frameLayer, toOpacity);
            
            id toOtherOpacity = @(otherOpacity);
            layerOpacityAnimate(_leftTopDot, toOtherOpacity);
            layerOpacityAnimate(_leftBottomDot, toOtherOpacity);
            layerOpacityAnimate(_rightTopDot, toOtherOpacity);
            layerOpacityAnimate(_rightBottomDot, toOtherOpacity);
            if (_frameType == JPClassicFrameType) {
                layerOpacityAnimate(_horTopLine, toOtherOpacity);
                layerOpacityAnimate(_horBottomLine, toOtherOpacity);
                layerOpacityAnimate(_verLeftLine, toOtherOpacity);
                layerOpacityAnimate(_verRightLine, toOtherOpacity);
            }
            
            id toMidDotOpacity = @(midDotOpacity);
            layerOpacityAnimate(_leftMidDot, toMidDotOpacity);
            layerOpacityAnimate(_rightMidDot, toMidDotOpacity);
            layerOpacityAnimate(_topMidDot, toMidDotOpacity);
            layerOpacityAnimate(_bottomMidDot, toMidDotOpacity);
        }
    } else {
        [self.blurView setIsMaskAlpha:!isPreview duration:0];
        _borderImageView.alpha = _isRound ? 0 : opacity;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self setupFrameLayerOpacity:opacity otherLayersOpacity:otherOpacity midDotOpacity:midDotOpacity];
    [CATransaction commit];
}

- (void)setBorderImage:(UIImage *)borderImage {
    _borderImage = borderImage;
    if (borderImage) {
        self.borderImageView.image = borderImage;
        _borderImageView.alpha = (_isPreview || _isRound) ? 0.0 : 1.0;
        _frameLayerLineW = _isRound ? 1.5 : 0.0;
    } else {
        [_borderImageView removeFromSuperview];
        _frameLayerLineW = _isRound ? 1.5 : 1.0;
    }
    [self setFrameType:_frameType];
}

- (void)setBorderImageRectInset:(CGPoint)borderImageRectInset {
    _borderImageRectInset = borderImageRectInset;
    _borderImageView.frame = self.borderImageViewFrame;
}

- (void)setFrameType:(JPImageresizerFrameType)frameType {
    _frameType = frameType;
    
    self.frameLayer.lineWidth = _frameLayerLineW;
    
    if (_borderImage) {
        [self updateShapeLayersStrokeColor];
        [_horTopLine removeFromSuperlayer];
        [_horBottomLine removeFromSuperlayer];
        [_verLeftLine removeFromSuperlayer];
        [_verRightLine removeFromSuperlayer];
        [_leftMidDot removeFromSuperlayer];
        [_rightMidDot removeFromSuperlayer];
        [_topMidDot removeFromSuperlayer];
        [_bottomMidDot removeFromSuperlayer];
        [_leftTopDot removeFromSuperlayer];
        [_leftBottomDot removeFromSuperlayer];
        [_rightTopDot removeFromSuperlayer];
        [_rightBottomDot removeFromSuperlayer];
        return;
    }
    
    CGFloat lineW = 0;
    if (frameType == JPConciseFrameType) {
        [_horTopLine removeFromSuperlayer];
        [_horBottomLine removeFromSuperlayer];
        [_verLeftLine removeFromSuperlayer];
        [_verRightLine removeFromSuperlayer];
        _isHideFrameLine = NO;
    } else {
        [self horTopLine];
        [self horBottomLine];
        [self verLeftLine];
        [self verRightLine];
        lineW = _arrLineW;
    }
    
    if (_isShowMidDots) {
        self.leftMidDot.lineWidth = lineW;
        self.rightMidDot.lineWidth = lineW;
        self.topMidDot.lineWidth = lineW;
        self.bottomMidDot.lineWidth = lineW;
    } else {
        [_leftMidDot removeFromSuperlayer];
        [_rightMidDot removeFromSuperlayer];
        [_topMidDot removeFromSuperlayer];
        [_bottomMidDot removeFromSuperlayer];
    }
    
    self.leftTopDot.lineWidth = lineW;
    self.leftBottomDot.lineWidth = lineW;
    self.rightTopDot.lineWidth = lineW;
    self.rightBottomDot.lineWidth = lineW;
    
    [self updateShapeLayersStrokeColor];
    [self updateAllLayersOpacity];
    if (!CGRectIsEmpty(_imageresizerFrame)) {
        [self updateImageresizerFrame:_imageresizerFrame animateDuration:0];
    }
}

- (void)setAnimationCurve:(JPAnimationCurve)animationCurve {
    _animationCurve = animationCurve;
    switch (animationCurve) {
        case JPAnimationCurveEaseInOut:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseInEaseOut;
            _animationOption = UIViewAnimationOptionCurveEaseInOut;
            break;
        case JPAnimationCurveEaseIn:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseIn;
            _animationOption = UIViewAnimationOptionCurveEaseIn;
            break;
        case JPAnimationCurveEaseOut:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionEaseOut;
            _animationOption = UIViewAnimationOptionCurveEaseOut;
            break;
        case JPAnimationCurveLinear:
            _kCAMediaTimingFunction = kCAMediaTimingFunctionLinear;
            _animationOption = UIViewAnimationOptionCurveLinear;
            break;
    }
}

- (void)setIsCanRecovery:(BOOL)isCanRecovery {
    _isCanRecovery = isCanRecovery;
    !self.imageresizerIsCanRecovery ? : self.imageresizerIsCanRecovery(isCanRecovery);
}

- (void)setIsPrepareToScale:(BOOL)isPrepareToScale {
    _isPrepareToScale = isPrepareToScale;
    !self.imageresizerIsPrepareToScale ? : self.imageresizerIsPrepareToScale(isPrepareToScale);
}

- (void)setInitialResizeWHScale:(CGFloat)initialResizeWHScale {
    if (initialResizeWHScale < 0.0) initialResizeWHScale = 0.0;
    _initialResizeWHScale = initialResizeWHScale;
    [self checkIsCanRecovery];
}

- (void)setIsShowMidDots:(BOOL)isShowMidDots {
    if (_isShowMidDots == isShowMidDots) return;
    _isShowMidDots = isShowMidDots;
    if (_borderImage || _isPreview) return;
    CGFloat opacity = isShowMidDots ? 1.0 : 0.0;
    _leftMidDot.opacity = opacity;
    _rightMidDot.opacity = opacity;
    _topMidDot.opacity = opacity;
    _bottomMidDot.opacity = opacity;
}

#pragma mark - getter

- (NSTimeInterval)defaultDuration {
    return _defaultDuration;
}

- (CGFloat)maxResizeX {
    return self.maxResizeFrame.origin.x;
}

- (CGFloat)maxResizeY {
    return self.maxResizeFrame.origin.y;
}

- (CGFloat)maxResizeW {
    return self.maxResizeFrame.size.width;
}

- (CGFloat)maxResizeH {
    return self.maxResizeFrame.size.height;
}

- (CGFloat)imageresizeX {
    return _imageresizerFrame.origin.x;
}

- (CGFloat)imageresizeY {
    return _imageresizerFrame.origin.y;
}

- (CGFloat)imageresizeW {
    return _imageresizerFrame.size.width;
}

- (CGFloat)imageresizeH {
    return _imageresizerFrame.size.height;
}

- (CGSize)imageresizerSize {
    CGFloat w = ((NSInteger)(self.imageresizerFrame.size.width)) * 1.0;
    CGFloat h = ((NSInteger)(self.imageresizerFrame.size.height)) * 1.0;
    return CGSizeMake(w, h);
}

- (CGSize)imageViewSzie {
    CGFloat w = ((NSInteger)(self.imageView.frame.size.width)) * 1.0;
    CGFloat h = ((NSInteger)(self.imageView.frame.size.height)) * 1.0;
    return [self isHorizontalDirection:_rotationDirection] ? CGSizeMake(h, w) : CGSizeMake(w, h);
}

- (CAShapeLayer *)frameLayer {
    if (!_frameLayer) {
        _frameLayer = [self createShapeLayer:1.0];
        _frameLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _frameLayer;
}

- (CAShapeLayer *)leftTopDot {
    if (!_leftTopDot) _leftTopDot = [self createShapeLayer:0];
    return _leftTopDot;
}

- (CAShapeLayer *)leftMidDot {
    if (!_leftMidDot) _leftMidDot = [self createShapeLayer:0];
    return _leftMidDot;
}

- (CAShapeLayer *)leftBottomDot {
    if (!_leftBottomDot) _leftBottomDot = [self createShapeLayer:0];
    return _leftBottomDot;
}

- (CAShapeLayer *)rightTopDot {
    if (!_rightTopDot) _rightTopDot = [self createShapeLayer:0];
    return _rightTopDot;
}

- (CAShapeLayer *)rightMidDot {
    if (!_rightMidDot) _rightMidDot = [self createShapeLayer:0];
    return _rightMidDot;
}

- (CAShapeLayer *)rightBottomDot {
    if (!_rightBottomDot) _rightBottomDot = [self createShapeLayer:0];
    return _rightBottomDot;
}

- (CAShapeLayer *)topMidDot {
    if (!_topMidDot) _topMidDot = [self createShapeLayer:0];
    return _topMidDot;
}

- (CAShapeLayer *)bottomMidDot {
    if (!_bottomMidDot) _bottomMidDot = [self createShapeLayer:0];
    return _bottomMidDot;
}

- (CAShapeLayer *)horTopLine {
    if (!_horTopLine) _horTopLine = [self createShapeLayer:0.5];
    return _horTopLine;
}

- (CAShapeLayer *)horBottomLine {
    if (!_horBottomLine) _horBottomLine = [self createShapeLayer:0.5];
    return _horBottomLine;
}

- (CAShapeLayer *)verLeftLine {
    if (!_verLeftLine) _verLeftLine = [self createShapeLayer:0.5];
    return _verLeftLine;
}

- (CAShapeLayer *)verRightLine {
    if (!_verRightLine) _verRightLine = [self createShapeLayer:0.5];
    return _verRightLine;
}

- (BOOL)edgeLineIsEnabled {
    if (_isArbitrarily) {
        return _edgeLineIsEnabled;
    } else {
        return NO;
    }
}

- (UIImageView *)borderImageView {
    if (!_borderImageView) {
        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:self.borderImageViewFrame];
        borderImageView.layer.minificationFilter = kCAFilterNearest;
        borderImageView.layer.magnificationFilter = kCAFilterNearest;
        [self addSubview:borderImageView];
        _borderImageView = borderImageView;
    }
    return _borderImageView;
}

- (CGRect)borderImageViewFrame {
    if (!CGRectIsEmpty(_imageresizerFrame)) {
        return CGRectInset(_imageresizerFrame, _borderImageRectInset.x, _borderImageRectInset.y);
    }
    return CGRectZero;
}

- (UIBlurEffect *)blurEffect {
    return self.blurView.blurEffect;
}

- (UIColor *)bgColor {
    return self.blurView.bgColor;
}

- (CGFloat)maskAlpha {
    return self.blurView.maskAlpha;
}

#pragma mark - init

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
imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale {
    
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        self.animationCurve = animationCurve;
        self.scrollView = scrollView;
        self.imageView = imageView;
        
        _defaultDuration = 0.27;
        _blurDuration = 0.3;
        _arrLineW = 2.5;
        _scopeWH = 50.0;
        _halfScopeWH = _scopeWH * 0.5;
        _minImageWH = 70.0;
        
        _edgeLineIsEnabled = YES;
        _rotationDirection = JPImageresizerVerticalUpDirection;
        _contentSize = contentSize;
        _horBaseMargin = horBaseMargin;
        _verBaseMargin = verBaseMargin;
        _imageresizerIsCanRecovery = [imageresizerIsCanRecovery copy];
        _imageresizerIsPrepareToScale = [imageresizerIsPrepareToScale copy];
        _strokeColor = strokeColor;
        _isShowMidDots = isShowMidDots;
        _diffRotLength = [UIScreen mainScreen].bounds.size.height - scrollView.bounds.size.height;
        
        CGRect blurFrame = CGRectInset(self.bounds, -_diffRotLength, -_diffRotLength);
        JPImageresizerBlurView *blurView = [[JPImageresizerBlurView alloc] initWithFrame:blurFrame blurEffect:blurEffect bgColor:bgColor maskAlpha:maskAlpha];
        blurView.userInteractionEnabled = NO;
        [self addSubview:blurView];
        self.blurView = blurView;
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = blurView.bounds;
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        blurView.layer.mask = maskLayer;
        self.maskLayer = maskLayer;
        
        _frameLayerLineW = isRoundResize ? 1.5 : (borderImage ? 0.0 : 1.0);
        _borderImageRectInset = borderImageRectInset;
        
        if (borderImage) {
            _frameType = frameType;
            self.borderImage = borderImage;
        } else {
            self.frameType = frameType;
        }
        
        if (isRoundResize) {
            [self roundResize:NO];
        } else {
            _dotWH = 12.0;
            _halfDotWH = _dotWH * 0.5;
            _halfArrLineW = _arrLineW * 0.5;
            _arrLength = 20.0;
            _midArrLength = _arrLength * 0.85;
            
            if (resizeWHScale == _resizeWHScale) _resizeWHScale = resizeWHScale + 1.0;
            self.resizeWHScale = resizeWHScale;
        }
        
        self.initialResizeWHScale = resizeWHScale;
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
        [self addGestureRecognizer:panGR];
        _panGR = panGR;
    }
    return self;
}

#pragma mark - life cycle

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) [self updateImageOriginFrameWithDirection:_rotationDirection duration:-1.0];
}

- (void)dealloc {
    [self willDie];
}

#pragma mark - override method

#ifdef __IPHONE_13_0
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.strokeColor = _strokeColor;
    self.bgColor = self.blurView.bgColor;
}
#endif

#pragma mark - timer

- (BOOL)addTimer {
    BOOL isHasTimer = [self removeTimer];
    self.timer = [NSTimer timerWithTimeInterval:0.65 target:[JPImageresizerProxy proxyWithTarget:self] selector:@selector(timerHandle) userInfo:nil repeats:NO]; // default 0.65
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    return isHasTimer;
}

- (BOOL)removeTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        return YES;
    }
    return NO;
}

- (void)timerHandle {
    [self removeTimer];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:_defaultDuration];
}

#pragma mark - assist method

- (void)willDie {
    self.window.userInteractionEnabled = YES;
    [self removeTimer];
}

- (CAShapeLayer *)createShapeLayer:(CGFloat)lineWidth {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = lineWidth;
    [self.layer addSublayer:shapeLayer];
    return shapeLayer;
}

- (BOOL)isHorizontalDirection:(JPImageresizerRotationDirection)direction {
    return (direction == JPImageresizerHorizontalLeftDirection ||
            direction == JPImageresizerHorizontalRightDirection);
}

- (UIBezierPath *)dotPathWithPosition:(CGPoint)position {
    return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(position.x - _halfDotWH, position.y - _halfDotWH, _dotWH, _dotWH)];
}

- (UIBezierPath *)arrPathWithPosition:(CGPoint)position dotRegion:(JPDotRegion)dotRegion {
    CGFloat arrLength = _arrLength;
    CGFloat halfArrLineW = _halfArrLineW;
    
    CGPoint startPoint = position;
    CGPoint endPoint = position;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    switch (dotRegion) {
        case JPDR_LeftTop:
        {
            position.x -= halfArrLineW;
            position.y -= halfArrLineW;
            startPoint = CGPointMake(position.x, position.y + arrLength);
            endPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
        case JPDR_LeftBottom:
        {
            position.x -= halfArrLineW;
            position.y += halfArrLineW;
            startPoint = CGPointMake(position.x, position.y - arrLength);
            endPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
        case JPDR_RightTop:
        {
            position.x += halfArrLineW;
            position.y -= halfArrLineW;
            startPoint = CGPointMake(position.x - arrLength, position.y);
            endPoint = CGPointMake(position.x, position.y + arrLength);
            break;
        }
        case JPDR_RightBottom:
        {
            position.x += halfArrLineW;
            position.y += halfArrLineW;
            startPoint = CGPointMake(position.x - arrLength, position.y);
            endPoint = CGPointMake(position.x, position.y - arrLength);
            break;
        }
        case JPDR_TopMid:
        {
            arrLength = _midArrLength;
            position.y -= halfArrLineW;
            startPoint = CGPointMake(position.x - arrLength, position.y);
            endPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
        case JPDR_BottomMid:
        {
            arrLength = _midArrLength;
            position.y += halfArrLineW;
            startPoint = CGPointMake(position.x - arrLength, position.y);
            endPoint = CGPointMake(position.x + arrLength, position.y);
            break;
        }
        case JPDR_LeftMid:
        {
            arrLength = _midArrLength;
            position.x -= halfArrLineW;
            startPoint = CGPointMake(position.x, position.y - arrLength);
            endPoint = CGPointMake(position.x, position.y + arrLength);
            break;
        }
        case JPDR_RightMid:
        {
            arrLength = _midArrLength;
            position.x += halfArrLineW;
            startPoint = CGPointMake(position.x, position.y - arrLength);
            endPoint = CGPointMake(position.x, position.y + arrLength);
            break;
        }
        default:
            break;
    }
    [path moveToPoint:startPoint];
    [path addLineToPoint:position];
    [path addLineToPoint:endPoint];
    return path;
}

- (UIBezierPath *)linePathWithLinePosition:(JPInsideLinePosition)linePosition location:(CGPoint)location length:(CGFloat)length {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    switch (linePosition) {
        case JPILP_HorTop:
        case JPILP_HorBottom:
        {
            point = CGPointMake(location.x + length, location.y);
            break;
        }
        case JPILP_VerLeft:
        case JPILP_VerRight:
        {
            point = CGPointMake(location.x, location.y + length);
            break;
        }
    }
    [path moveToPoint:location];
    [path addLineToPoint:point];
    return path;
}

- (BOOL)imageresizerFrameIsEqualImageViewFrame {
    CGSize imageresizerSize = self.imageresizerSize;
    CGSize imageViewSzie = self.imageViewSzie;
    CGFloat resizeWHScale = [self isHorizontalDirection:_rotationDirection] ? (1.0 / _resizeWHScale) : _resizeWHScale;
    if (_isArbitrarily || (resizeWHScale == _originWHScale)) {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 &&
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    } else {
        return (fabs(imageresizerSize.width - imageViewSzie.width) <= 1 ||
                fabs(imageresizerSize.height - imageViewSzie.height) <= 1);
    }
}

- (CGRect)baseImageresizerFrame {
    if (_isArbitrarily) {
        return self.originImageFrame;
    } else {
        CGFloat w = 0;
        CGFloat h = 0;
        if ([self isHorizontalDirection:_rotationDirection]) {
            h = _baseImageW;
            w = h * _resizeWHScale;
            if (w > self.maxResizeW) {
                w = self.maxResizeW;
                h = w / _resizeWHScale;
            }
        } else {
            w = _baseImageW;
            h = w / _resizeWHScale;
            if (h > self.maxResizeH) {
                h = self.maxResizeH;
                w = h * _resizeWHScale;
            }
        }
        CGFloat x = self.maxResizeX + (self.maxResizeW - w) * 0.5;
        CGFloat y = self.maxResizeY + (self.maxResizeH - h) * 0.5;
        return CGRectMake(x, y, w, h);
    }
}

- (CGRect)adjustResizeFrame {
    CGFloat resizeWHScale = _isArbitrarily ? (self.imageresizeW / self.imageresizeH) : _resizeWHScale;
    CGFloat adjustResizeW = 0;
    CGFloat adjustResizeH = 0;
    if (resizeWHScale >= 1) {
        adjustResizeW = self.maxResizeW;
        adjustResizeH = adjustResizeW / resizeWHScale;
        if (adjustResizeH > self.maxResizeH) {
            adjustResizeH = self.maxResizeH;
            adjustResizeW = self.maxResizeH * resizeWHScale;
        }
    } else {
        adjustResizeH = self.maxResizeH;
        adjustResizeW = adjustResizeH * resizeWHScale;
        if (adjustResizeW > self.maxResizeW) {
            adjustResizeW = self.maxResizeW;
            adjustResizeH = adjustResizeW / resizeWHScale;
        }
    }
    CGFloat adjustResizeX = self.maxResizeX + (self.maxResizeW - adjustResizeW) * 0.5;
    CGFloat adjustResizeY = self.maxResizeY + (self.maxResizeH - adjustResizeH) * 0.5;
    return CGRectMake(adjustResizeX, adjustResizeY, adjustResizeW, adjustResizeH);
}

#pragma mark - private method

- (void)updateShapeLayersStrokeColor {
    CGColorRef strokeCGColor = _strokeColor.CGColor;
    _frameLayer.strokeColor = strokeCGColor;
    
    if (_borderImage) return;
    CGColorRef clearCGColor = [UIColor clearColor].CGColor;
    
    CGColorRef dotFillColor;
    CGColorRef dotStrokeColor;
    if (_frameType == JPConciseFrameType) {
        dotFillColor = strokeCGColor;
        dotStrokeColor = clearCGColor;
    } else {
        dotFillColor = clearCGColor;
        dotStrokeColor = strokeCGColor;
        _horTopLine.strokeColor = strokeCGColor;
        _horBottomLine.strokeColor = strokeCGColor;
        _verLeftLine.strokeColor = strokeCGColor;
        _verRightLine.strokeColor = strokeCGColor;
    }
    
    // setup fillColor
    _leftTopDot.fillColor = dotFillColor;
    _leftBottomDot.fillColor = dotFillColor;
    _rightTopDot.fillColor = dotFillColor;
    _rightBottomDot.fillColor = dotFillColor;
    
    _leftMidDot.fillColor = dotFillColor;
    _rightMidDot.fillColor = dotFillColor;
    _topMidDot.fillColor = dotFillColor;
    _bottomMidDot.fillColor = dotFillColor;
    
    // setup strokeColor
    _leftTopDot.strokeColor = dotStrokeColor;
    _leftBottomDot.strokeColor = dotStrokeColor;
    _rightTopDot.strokeColor = dotStrokeColor;
    _rightBottomDot.strokeColor = dotStrokeColor;
    
    _leftMidDot.strokeColor = dotStrokeColor;
    _rightMidDot.strokeColor = dotStrokeColor;
    _topMidDot.strokeColor = dotStrokeColor;
    _bottomMidDot.strokeColor = dotStrokeColor;
}

- (void)updateAllLayersOpacity {
    CGFloat opacity = _isPreview ? 0 : 1;
    CGFloat otherOpacity = _isRound ? 0 : opacity;
    CGFloat midDotOpacity = (_isShowMidDots && !_isRound) ? opacity : 0.0;
    [self setupFrameLayerOpacity:opacity otherLayersOpacity:otherOpacity midDotOpacity:midDotOpacity];
}
    
- (void)setupFrameLayerOpacity:(CGFloat)flOpacity otherLayersOpacity:(CGFloat)olOpacity midDotOpacity:(CGFloat)mdOpacity {
    _frameLayer.opacity = flOpacity;
    if (_borderImage) return;
    
    _leftTopDot.opacity = olOpacity;
    _leftBottomDot.opacity = olOpacity;
    _rightTopDot.opacity = olOpacity;
    _rightBottomDot.opacity = olOpacity;
    
    if (_frameType == JPClassicFrameType) {
        _horTopLine.opacity = olOpacity;
        _horBottomLine.opacity = olOpacity;
        _verLeftLine.opacity = olOpacity;
        _verRightLine.opacity = olOpacity;
    }
    
    _leftMidDot.opacity = mdOpacity;
    _rightMidDot.opacity = mdOpacity;
    _topMidDot.opacity = mdOpacity;
    _bottomMidDot.opacity = mdOpacity;
}

- (void)hideOrShowFrameLine:(BOOL)isHide animateDuration:(NSTimeInterval)duration {
    if (_frameType != JPClassicFrameType) return;
    if (_borderImage) return;
    if (_isRound) return;
    if (_isHideFrameLine == isHide) return;
    _isHideFrameLine = isHide;
    CGFloat toOpacity = isHide ? 0 : 1;
    if (duration > 0) {
        CGFloat fromOpacity = isHide ? 1 : 0;
        NSString *keyPath = @"opacity";
        CABasicAnimation *anim = [CABasicAnimation jpir_backwardsAnimationWithKeyPath:keyPath fromValue:@(fromOpacity) toValue:@(toOpacity) timingFunctionName:_kCAMediaTimingFunction duration:duration];
        [_horTopLine addAnimation:anim forKey:keyPath];
        [_horBottomLine addAnimation:anim forKey:keyPath];
        [_verLeftLine addAnimation:anim forKey:keyPath];
        [_verRightLine addAnimation:anim forKey:keyPath];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _horTopLine.opacity = toOpacity;
    _horBottomLine.opacity = toOpacity;
    _verLeftLine.opacity = toOpacity;
    _verRightLine.opacity = toOpacity;
    [CATransaction commit];
}

- (void)updateImageresizerFrame:(CGRect)imageresizerFrame animateDuration:(NSTimeInterval)duration {
    _imageresizerFrame = imageresizerFrame;
    
    CGFloat radius = _isRound ? imageresizerFrame.size.width * 0.5 : 0.1;
    
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRoundedRect:imageresizerFrame cornerRadius:radius];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.blurView.bounds];
    CGRect maskFrame = imageresizerFrame;
    maskFrame.origin.x += _diffRotLength;
    maskFrame.origin.y += _diffRotLength;
    [maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:maskFrame cornerRadius:radius]];
    
    if (_borderImage) {
        CGRect borderImageViewFrame = self.borderImageViewFrame;
        if (duration > 0) {
            CAMediaTimingFunctionName timingFunctionName = _kCAMediaTimingFunction;
            void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *path) = ^(CAShapeLayer *layer, UIBezierPath *path) {
                if (!layer) return;
                [layer jpir_addBackwardsAnimationWithKeyPath:@"path" fromValue:(id)layer.path toValue:path timingFunctionName:timingFunctionName duration:duration];
            };
            
            [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
                self.borderImageView.frame = borderImageViewFrame;
            } completion:nil];
            layerPathAnimate(_maskLayer, maskPath);
            layerPathAnimate(_frameLayer, framePath);
        } else {
            _borderImageView.frame = borderImageViewFrame;
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _maskLayer.path = maskPath.CGPath;
        _frameLayer.path = framePath.CGPath;
        [CATransaction commit];
        return;
    }
    
    CGFloat imageresizerX = imageresizerFrame.origin.x;
    CGFloat imageresizerY = imageresizerFrame.origin.y;
    CGFloat imageresizerMidX = CGRectGetMidX(imageresizerFrame);
    CGFloat imageresizerMidY = CGRectGetMidY(imageresizerFrame);
    CGFloat imageresizerMaxX = CGRectGetMaxX(imageresizerFrame);
    CGFloat imageresizerMaxY = CGRectGetMaxY(imageresizerFrame);
    
    UIBezierPath *leftTopDotPath;
    UIBezierPath *leftBottomDotPath;
    UIBezierPath *rightTopDotPath;
    UIBezierPath *rightBottomDotPath;
    
    UIBezierPath *leftMidDotPath;
    UIBezierPath *rightMidDotPath;
    UIBezierPath *topMidDotPath;
    UIBezierPath *bottomMidDotPath;
    
    UIBezierPath *horTopLinePath;
    UIBezierPath *horBottomLinePath;
    UIBezierPath *verLeftLinePath;
    UIBezierPath *verRightLinePath;
    
    if (_frameType == JPConciseFrameType) {
        if (_isRound) {
            CGPoint center = CGPointMake(imageresizerMidX, imageresizerMidY);
            CGFloat radius = imageresizerFrame.size.width * 0.5;
            CGFloat lineLength = sqrt(pow(radius, 2) * 0.5);
            
            leftTopDotPath = [self dotPathWithPosition:CGPointMake(center.x - lineLength, center.y - lineLength)];
            leftBottomDotPath = [self dotPathWithPosition:CGPointMake(center.x - lineLength, center.y + lineLength)];
            rightTopDotPath = [self dotPathWithPosition:CGPointMake(center.x + lineLength, center.y - lineLength)];
            rightBottomDotPath = [self dotPathWithPosition:CGPointMake(center.x + lineLength, center.y + lineLength)];
        } else {
            leftTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerY)];
            leftBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY)];
            rightTopDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY)];
            rightBottomDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY)];
        }
        
        leftMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerX, imageresizerMidY)];
        rightMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMidY)];
        topMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerY)];
        bottomMidDotPath = [self dotPathWithPosition:CGPointMake(imageresizerMidX, imageresizerMaxY)];
    } else {
        if (_isRound) {
            CGPoint center = CGPointMake(imageresizerMidX, imageresizerMidY);
            CGFloat radius = imageresizerFrame.size.width * 0.5;
            CGFloat lineLength = sqrt(pow(radius, 2) * 0.5);
            
            leftTopDotPath = [self arrPathWithPosition:CGPointMake(center.x - lineLength, center.y - lineLength) dotRegion:JPDR_LeftTop];
            leftBottomDotPath = [self arrPathWithPosition:CGPointMake(center.x - lineLength, center.y + lineLength) dotRegion:JPDR_LeftBottom];
            rightTopDotPath = [self arrPathWithPosition:CGPointMake(center.x + lineLength, center.y - lineLength) dotRegion:JPDR_RightTop];
            rightBottomDotPath = [self arrPathWithPosition:CGPointMake(center.x + lineLength, center.y + lineLength) dotRegion:JPDR_RightBottom];
        } else {
            leftTopDotPath = [self arrPathWithPosition:CGPointMake(imageresizerX, imageresizerY) dotRegion:JPDR_LeftTop];
            leftBottomDotPath = [self arrPathWithPosition:CGPointMake(imageresizerX, imageresizerMaxY) dotRegion:JPDR_LeftBottom];
            rightTopDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerY) dotRegion:JPDR_RightTop];
            rightBottomDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMaxY) dotRegion:JPDR_RightBottom];
        }
        
        leftMidDotPath = [self arrPathWithPosition:CGPointMake(imageresizerX, imageresizerMidY) dotRegion:JPDR_LeftMid];
        rightMidDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMaxX, imageresizerMidY) dotRegion:JPDR_RightMid];
        topMidDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMidX, imageresizerY) dotRegion:JPDR_TopMid];
        bottomMidDotPath = [self arrPathWithPosition:CGPointMake(imageresizerMidX, imageresizerMaxY) dotRegion:JPDR_BottomMid];
        
        CGFloat imageresizerW = imageresizerFrame.size.width;
        CGFloat imageresizerH = imageresizerFrame.size.height;
        CGFloat oneThirdW = imageresizerW / 3.0;
        CGFloat oneThirdH = imageresizerH / 3.0;
        
        horTopLinePath = [self linePathWithLinePosition:JPILP_HorTop location:CGPointMake(imageresizerX, imageresizerY + oneThirdH) length:imageresizerW];
        horBottomLinePath = [self linePathWithLinePosition:JPILP_HorBottom location:CGPointMake(imageresizerX, imageresizerY + oneThirdH * 2) length:imageresizerW];
        verLeftLinePath = [self linePathWithLinePosition:JPILP_VerLeft location:CGPointMake(imageresizerX + oneThirdW, imageresizerY) length:imageresizerH];
        verRightLinePath = [self linePathWithLinePosition:JPILP_VerRight location:CGPointMake(imageresizerX + oneThirdW * 2, imageresizerY) length:imageresizerH];
    }
    
    if (duration > 0) {
        CAMediaTimingFunctionName timingFunctionName = _kCAMediaTimingFunction;
        void (^layerPathAnimate)(CAShapeLayer *layer, UIBezierPath *path) = ^(CAShapeLayer *layer, UIBezierPath *path) {
            if (!layer) return;
            [layer jpir_addBackwardsAnimationWithKeyPath:@"path" fromValue:(id)layer.path toValue:path timingFunctionName:timingFunctionName duration:duration];
        };
        
        if (_leftTopDot.opacity) {
            layerPathAnimate(_leftTopDot, leftTopDotPath);
            layerPathAnimate(_leftBottomDot, leftBottomDotPath);
            layerPathAnimate(_rightTopDot, rightTopDotPath);
            layerPathAnimate(_rightBottomDot, rightBottomDotPath);
        }
        
        if (_leftMidDot.opacity) {
            layerPathAnimate(_leftMidDot, leftMidDotPath);
            layerPathAnimate(_rightMidDot, rightMidDotPath);
            layerPathAnimate(_topMidDot, topMidDotPath);
            layerPathAnimate(_bottomMidDot, bottomMidDotPath);
        }
        
        if (_frameType == JPClassicFrameType) {
            layerPathAnimate(_horTopLine, horTopLinePath);
            layerPathAnimate(_horBottomLine, horBottomLinePath);
            layerPathAnimate(_verLeftLine, verLeftLinePath);
            layerPathAnimate(_verRightLine, verRightLinePath);
        }
        
        layerPathAnimate(_maskLayer, maskPath);
        layerPathAnimate(_frameLayer, framePath);
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    _leftTopDot.path = leftTopDotPath.CGPath;
    _leftBottomDot.path = leftBottomDotPath.CGPath;
    _rightTopDot.path = rightTopDotPath.CGPath;
    _rightBottomDot.path = rightBottomDotPath.CGPath;
    
    _leftMidDot.path = leftMidDotPath.CGPath;
    _rightMidDot.path = rightMidDotPath.CGPath;
    _topMidDot.path = topMidDotPath.CGPath;
    _bottomMidDot.path = bottomMidDotPath.CGPath;
    
    if (_frameType == JPClassicFrameType) {
        _horTopLine.path = horTopLinePath.CGPath;
        _horBottomLine.path = horBottomLinePath.CGPath;
        _verLeftLine.path = verLeftLinePath.CGPath;
        _verRightLine.path = verRightLinePath.CGPath;
    }
    
    _maskLayer.path = maskPath.CGPath;
    _frameLayer.path = framePath.CGPath;
    
    [CATransaction commit];
}

- (void)updateImageOriginFrameWithDirection:(JPImageresizerRotationDirection)rotationDirection duration:(NSTimeInterval)duration {
    [self removeTimer];
    _baseImageW = self.imageView.bounds.size.width;
    _baseImageH = self.imageView.bounds.size.height;
    _diffHalfW = (self.bounds.size.width - _contentSize.width) * 0.5;
    CGFloat x = (self.bounds.size.width - _baseImageW) * 0.5;
    CGFloat y = (self.bounds.size.height - _baseImageH) * 0.5;
    self.originImageFrame = CGRectMake(x, y, _baseImageW, _baseImageH);
    [self updateRotationDirection:rotationDirection];
    _imageresizerFrame = [self baseImageresizerFrame];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:duration];
}

- (void)updateRotationDirection:(JPImageresizerRotationDirection)rotationDirection {
    [self updateMaxResizeFrameWithDirection:rotationDirection];
    if (!_isArbitrarily) {
        BOOL isSwitchVerHor = [self isHorizontalDirection:_rotationDirection] != [self isHorizontalDirection:rotationDirection];
        if (isSwitchVerHor) _resizeWHScale = 1.0 / _resizeWHScale;
    }
    _rotationDirection = rotationDirection;
}

- (void)updateMaxResizeFrameWithDirection:(JPImageresizerRotationDirection)direction {
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    if ([self isHorizontalDirection:direction]) {
        x = (w - _contentSize.height) * 0.5 +  _verBaseMargin;
        y = (h - _contentSize.width) * 0.5 + _horBaseMargin;
    } else {
        x = _diffHalfW + _horBaseMargin;
        y = _verBaseMargin;
    }
    w -= 2 * x;
    h -= 2 * y;
    self.maxResizeFrame = CGRectMake(x, y, w, h);
    
    self.frameLayer.lineWidth = _frameLayerLineW;
    
    if (_borderImage) return;
    
    CGFloat lineW = 0;
    if (_frameType == JPClassicFrameType) {
        _horTopLine.lineWidth = 0.5;
        _horBottomLine.lineWidth = 0.5;
        _verLeftLine.lineWidth = 0.5;
        _verRightLine.lineWidth = 0.5;
        lineW = _arrLineW;
    }
    
    _leftTopDot.lineWidth = lineW;
    _leftBottomDot.lineWidth = lineW;
    _rightTopDot.lineWidth = lineW;
    _rightBottomDot.lineWidth = lineW;
    
    _leftMidDot.lineWidth = lineW;
    _rightMidDot.lineWidth = lineW;
    _topMidDot.lineWidth = lineW;
    _bottomMidDot.lineWidth = lineW;
}

- (void)adjustImageresizerFrame:(CGRect)adjustResizeFrame
          isAdvanceUpdateOffset:(BOOL)isAdvanceUpdateOffset
                animateDuration:(NSTimeInterval)duration {
    CGRect imageresizerFrame = self.imageresizerFrame;
    UIScrollView *scrollView = self.scrollView;
    UIImageView *imageView = self.imageView;
    
    // zoomFrame
    // 根据裁剪的区域，因为需要有间距，所以拼接成self的尺寸获取缩放的区域zoomFrame
    // 宽高比不变，所以宽度高度的比例是一样，这里就用宽度比例吧
    CGFloat convertScale = imageresizerFrame.size.width / adjustResizeFrame.size.width;
    CGFloat dx = -adjustResizeFrame.origin.x * convertScale;
    CGFloat dy = -adjustResizeFrame.origin.y * convertScale;
    CGRect convertZoomFrame = CGRectInset(imageresizerFrame, dx, dy);
    // 边沿检测，到顶就往外取值，防止有空隙
    CGRect convertImageresizerFrame = [self convertRect:imageresizerFrame toView:scrollView];
    BOOL isTheTop = fabs(convertImageresizerFrame.origin.y - imageView.frame.origin.y) < 1.0;
    BOOL isTheLead = fabs(convertImageresizerFrame.origin.x - imageView.frame.origin.x) < 1.0;
    BOOL isTheBottom = fabs(CGRectGetMaxY(convertImageresizerFrame) - CGRectGetMaxY(imageView.frame)) < 1.0;
    BOOL isTheTrail = fabs(CGRectGetMaxX(convertImageresizerFrame) - CGRectGetMaxX(imageView.frame)) < 1.0;
    if (isTheTop) convertZoomFrame.origin.y -= 1.0;
    if (isTheLead) convertZoomFrame.origin.x -= 1.0;
    if (isTheBottom) convertZoomFrame.size.height += 1.0;
    if (isTheTrail) convertZoomFrame.size.width += 1.0;
    CGRect zoomFrame = [self convertRect:convertZoomFrame toView:imageView];
    
    // contentInset
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:adjustResizeFrame];
    
    // contentOffset
    CGPoint contentOffset = scrollView.contentOffset;
    if (isAdvanceUpdateOffset) {
        contentOffset = [self convertPoint:imageresizerFrame.origin toView:imageView];
        contentOffset.x = -contentInset.left + contentOffset.x * scrollView.zoomScale;
        contentOffset.y = -contentInset.top + contentOffset.y * scrollView.zoomScale;
    }
    
    // minimumZoomScale
    scrollView.minimumZoomScale = [self scrollViewMinZoomScaleWithResizeSize:adjustResizeFrame.size];
    
    void (^zoomBlock)(void) = ^{
        [scrollView setContentInset:contentInset];
        if (isAdvanceUpdateOffset) {
            [scrollView setContentOffset:contentOffset animated:NO];
        }
        [scrollView zoomToRect:zoomFrame animated:NO];
        if (!isAdvanceUpdateOffset) {
            CGPoint offset = [self convertPoint:self.imageresizerFrame.origin toView:imageView];
            offset.x = -contentInset.left + offset.x * scrollView.zoomScale;
            offset.y = -contentInset.top + offset.y * scrollView.zoomScale;
            [scrollView setContentOffset:offset animated:NO];
        }
    };
    
    void (^completeBlock)(void) = ^{
        [self.blurView setIsBlur:YES duration:self->_blurDuration];
        self.superview.userInteractionEnabled = YES;
        if (self->_isToBeArbitrarily) {
            self->_isToBeArbitrarily = NO;
            self->_resizeWHScale = 0;
            self->_isArbitrarily = YES;
        }
        [self checkIsCanRecovery];
        self.isPrepareToScale = NO;
    };
    
    self.superview.userInteractionEnabled = NO;
    [self hideOrShowFrameLine:NO animateDuration:_blurDuration];
    [self updateImageresizerFrame:adjustResizeFrame animateDuration:duration];
    if (duration > 0) {
        [UIView animateWithDuration:duration delay:0 options:_animationOption animations:^{
            zoomBlock();
        } completion:^(BOOL finished) {
            if (finished) completeBlock();
        }];
    } else {
        zoomBlock();
        completeBlock();
    }
}

- (UIEdgeInsets)scrollViewContentInsetWithAdjustResizeFrame:(CGRect)adjustResizeFrame {
    // scrollView宽高跟self一样，上下左右不需要额外添加Space
    CGFloat top = adjustResizeFrame.origin.y; // + veSpace?
    CGFloat bottom = self.bounds.size.height - CGRectGetMaxY(adjustResizeFrame); // + veSpace?
    CGFloat left = adjustResizeFrame.origin.x; // + hoSpace?
    CGFloat right = self.bounds.size.width - CGRectGetMaxX(adjustResizeFrame); // + hoSpace?
    return UIEdgeInsetsMake(top, left, bottom, right);
}

- (CGFloat)scrollViewMinZoomScaleWithResizeSize:(CGSize)size {
    CGFloat length;
    CGFloat baseLength;
    CGFloat width;
    CGFloat baseWidth;
    if (size.width >= size.height) {
        length = size.width;
        baseLength = _baseImageW;
        width = size.height;
        baseWidth = _baseImageH;
    } else {
        length = size.height;
        baseLength = _baseImageH;
        width = size.width;
        baseWidth = _baseImageW;
    }
    CGFloat minZoomScale = length / baseLength;
    CGFloat scaleWidth = baseWidth * minZoomScale;
    if (scaleWidth < width) {
        minZoomScale *= (width / scaleWidth);
    }
    return minZoomScale;
}

- (void)checkIsCanRecovery {
    if (self.resizeWHScale != self.initialResizeWHScale) {
        self.isCanRecovery = YES;
        return;
    }
    
    BOOL isVerticalityMirror = self.isVerticalityMirror ? self.isVerticalityMirror() : NO;
    BOOL isHorizontalMirror = self.isHorizontalMirror ? self.isHorizontalMirror() : NO;
    if (isVerticalityMirror || isHorizontalMirror) {
        self.isCanRecovery = YES;
        return;
    }
    
    CGPoint convertCenter = [self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:self.imageView];
    CGPoint imageViewCenter = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
    BOOL isSameCenter = labs((NSInteger)convertCenter.x - (NSInteger)imageViewCenter.x) <= 1 && labs((NSInteger)convertCenter.y - (NSInteger)imageViewCenter.y) <= 1;
    BOOL isOriginFrame = self.rotationDirection == JPImageresizerVerticalUpDirection && [self imageresizerFrameIsEqualImageViewFrame];
    self.isCanRecovery = !isOriginFrame || !isSameCenter;
}

#pragma mark - puild method

- (void)updateFrameType:(JPImageresizerFrameType)frameType {
    if (self.frameType == frameType) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.frameType = frameType;
    [CATransaction commit];
}

- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated {
    void (^animations)(void) = ^{
        self.strokeColor = strokeColor;
        [self.blurView setupIsBlur:self.blurView.isBlur
                        blurEffect:blurEffect
                           bgColor:bgColor
                         maskAlpha:maskAlpha
                       isMaskAlpha:self.blurView.isMaskAlpha
                          duration:0];
        self.superview.layer.backgroundColor = bgColor.CGColor;
    };
    if (isAnimated) {
        [UIView animateWithDuration:_defaultDuration delay:0 options:_animationOption animations:animations completion:nil];
    } else {
        animations();
    }
}

- (void)updateImageresizerFrameWithVerBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin duration:(NSTimeInterval)duration {
    _verBaseMargin = verBaseMargin;
    _horBaseMargin = horBaseMargin;
    self.layer.transform = CATransform3DIdentity;
    [self updateImageOriginFrameWithDirection:JPImageresizerVerticalUpDirection duration:duration];
}

- (void)startImageresizer {
    self.isPrepareToScale = YES;
    [self removeTimer];
    [self.blurView setIsBlur:NO duration:_blurDuration];
    [self hideOrShowFrameLine:YES animateDuration:_blurDuration];
}

- (void)endedImageresizer {
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:self.imageresizerFrame];
    self.scrollView.contentInset = contentInset;
    [self addTimer];
}

- (void)rotationWithDirection:(JPImageresizerRotationDirection)direction rotationDuration:(NSTimeInterval)rotationDuration {
    [self removeTimer];
    [self updateRotationDirection:direction];
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:rotationDuration];
}

- (void)willMirror:(BOOL)animated {
    self.window.userInteractionEnabled = NO;
    if (animated) [self.blurView setIsBlur:NO duration:0];
}

- (void)verticalityMirrorWithDiffX:(CGFloat)diffX {
    CGFloat w = [self isHorizontalDirection:_rotationDirection] ? self.bounds.size.height : self.bounds.size.width;
    CGFloat x = (_contentSize.width - w) * 0.5 + diffX;
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.scrollView.frame = frame;
    self.frame = frame;
}

- (void)horizontalMirrorWithDiffY:(CGFloat)diffY {
    CGFloat h = [self isHorizontalDirection:_rotationDirection] ? self.bounds.size.width : self.bounds.size.height;
    CGFloat y = (_contentSize.height - h) * 0.5 + diffY;
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.scrollView.frame = frame;
    self.frame = frame;
}

- (void)mirrorDone {
    [self.blurView setIsBlur:YES duration:_blurDuration];
    [self checkIsCanRecovery];
    self.window.userInteractionEnabled = YES;
}

- (void)willRecoveryToRoundResize {
    self.window.userInteractionEnabled = NO;
    [self removeTimer];
    _isRound = YES;
    _resizeWHScale = 1;
    _isArbitrarily = NO;
    _isToBeArbitrarily = NO;
}

- (void)willRecoveryByResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily {
    self.window.userInteractionEnabled = NO;
    [self removeTimer];
    _isRound = NO;
    _resizeWHScale = resizeWHScale;
    _isArbitrarily = resizeWHScale <= 0;
    _isToBeArbitrarily = isToBeArbitrarily;
}

- (void)recoveryWithDuration:(NSTimeInterval)duration {
    [self updateRotationDirection:JPImageresizerVerticalUpDirection];
    
    CGRect adjustResizeFrame = _isArbitrarily ? [self baseImageresizerFrame] : [self adjustResizeFrame];
    
    UIEdgeInsets contentInset = [self scrollViewContentInsetWithAdjustResizeFrame:adjustResizeFrame];
    
    CGFloat minZoomScale = [self scrollViewMinZoomScaleWithResizeSize:adjustResizeFrame.size];
    
    CGFloat offsetX = -contentInset.left + (_baseImageW * minZoomScale - adjustResizeFrame.size.width) * 0.5;
    CGFloat offsetY = -contentInset.top + (_baseImageH * minZoomScale - adjustResizeFrame.size.height) * 0.5;
    CGPoint contentOffset = CGPointMake(offsetX, offsetY);
    
    [self updateImageresizerFrame:adjustResizeFrame animateDuration:duration];
    
    self.scrollView.minimumZoomScale = minZoomScale;
    self.scrollView.zoomScale = minZoomScale;
    self.scrollView.contentInset = contentInset;
    self.scrollView.contentOffset = contentOffset;
}

- (void)recoveryDone {
    [self adjustImageresizerFrame:[self adjustResizeFrame] isAdvanceUpdateOffset:YES animateDuration:-1.0];
    self.window.userInteractionEnabled = YES;
}

- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete compressScale:(CGFloat)compressScale {
    if (!complete) return;
    if (compressScale <= 0) {
        complete(nil);
        return;
    }
    
    /**
     * UIImageOrientationUp --------- default orientation
     * UIImageOrientationDown ----- 180 deg rotation
     * UIImageOrientationLeft -------- 90 deg CCW
     * UIImageOrientationRight ------ 90 deg CW
     */
    UIImageOrientation orientation;
    switch (self.rotationDirection) {
        case JPImageresizerHorizontalLeftDirection:
            orientation = UIImageOrientationLeft;
            break;
        case JPImageresizerVerticalDownDirection:
            orientation = UIImageOrientationDown;
            break;
        case JPImageresizerHorizontalRightDirection:
            orientation = UIImageOrientationRight;
            break;
        default:
            orientation = UIImageOrientationUp;
            break;
    }
    
    BOOL isVerMirror = self.isVerticalityMirror ? self.isVerticalityMirror() : NO;
    BOOL isHorMirror = self.isHorizontalMirror ? self.isHorizontalMirror() : NO;
    if ([self isHorizontalDirection:_rotationDirection]) {
        BOOL temp = isVerMirror;
        isVerMirror = isHorMirror;
        isHorMirror = temp;
    }
    
    UIImage *image = self.imageView.image;
    
    CGRect imageViewBounds = self.imageView.bounds;
    
    CGRect cropFrame = (self.isCanRecovery || self.resizeWHScale > 0) ? [self convertRect:self.imageresizerFrame toView:self.imageView] : imageViewBounds;
    
    CGFloat relativeWidth = imageViewBounds.size.width;
    
    BOOL isRoundClip = _isRound;
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(wSelf) sSelf = wSelf;
        if (!sSelf) return;
        UIImage *resultImage = [UIImage jpir_resultImageWithImage:image
                                                        cropFrame:cropFrame
                                                    relativeWidth:relativeWidth
                                                      isVerMirror:isVerMirror
                                                      isHorMirror:isHorMirror
                                                rotateOrientation:orientation
                                                      isRoundClip:isRoundClip
                                                    compressScale:compressScale];
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(resultImage);
        });
    });
}

#pragma mark - UIPanGestureRecognizer

- (void)panHandle:(UIPanGestureRecognizer *)panGR {
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self startImageresizer];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self panChangedHandleWithTranslation:[panGR translationInView:self]];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self endedImageresizer];
            break;
        }
        default:
            break;
    }
    [panGR setTranslation:CGPointZero inView:self];
}

- (void)panChangedHandleWithTranslation:(CGPoint)translation {
    
    CGFloat x = _imageresizerFrame.origin.x;
    CGFloat y = _imageresizerFrame.origin.y;
    CGFloat w = _imageresizerFrame.size.width;
    CGFloat h = _imageresizerFrame.size.height;
    
    switch (_currDR) {
            
        case JPDR_LeftTop: {
            if (_isArbitrarily) {
                x += translation.x;
                y += translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                w = _diagonal.x - x;
                h = _diagonal.y - y;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                    x = _diagonal.x - w;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                    y = _diagonal.y - h;
                }
            } else {
                x += translation.x;
                w = _diagonal.x - x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y += diff;
                    h = _diagonal.y - y;
                }
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    w = _diagonal.x - x;
                    h = w / _resizeWHScale;
                    y = _diagonal.y - h;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    h = _diagonal.y - y;
                    w = h * _resizeWHScale;
                    x = _diagonal.x - w;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x - w;
                    y = _diagonal.y - h;
                }
            }
            
            break;
        }
            
        case JPDR_LeftBottom: {
            if (_isArbitrarily) {
                x += translation.x;
                h += translation.y;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                }
                
                w = _diagonal.x - x;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                    x = _diagonal.x - w;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                }
            } else {
                x += translation.x;
                w = _diagonal.x - x;
                
                if (translation.x != 0) {
                    h = w / _resizeWHScale;
                }
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    w = _diagonal.x - x;
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                    w = h * _resizeWHScale;
                    x = _diagonal.x - w;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x - w;
                    y = _diagonal.y;
                }
            }
            
            break;
        }
            
        case JPDR_RightTop: {
            if (_isArbitrarily) {
                y += translation.y;
                w += translation.x;
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                }
                
                h = _diagonal.y - y;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                    y = _diagonal.y - h;
                }
            } else {
                w += translation.x;
                
                if (translation.x != 0) {
                    CGFloat diff = translation.x / _resizeWHScale;
                    y -= diff;
                    h = _diagonal.y - y;
                }
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    h = _diagonal.y - y;
                    w = h * _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                    h = w / _resizeWHScale;
                    y = _diagonal.y - h;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x;
                    y = _diagonal.y - h;
                }
            }
            
            break;
        }
            
        case JPDR_RightBottom: {
            if (_isArbitrarily) {
                w += translation.x;
                h += translation.y;
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                }
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                }
            } else {
                w += translation.x;
                
                if (translation.x != 0) {
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                    h = w / _resizeWHScale;
                }
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                    w = h * _resizeWHScale;
                }
                
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                    x = _diagonal.x;
                    y = _diagonal.y;
                }
            }
            
            break;
        }
            
        case JPDR_LeftMid: {
            if (_isArbitrarily) {
                x += translation.x;
                
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
                
                w = _diagonal.x - x;
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                    x = _diagonal.x - w;
                }
            } else {
                w -= translation.x;
                h = w / _resizeWHScale;
                
                CGFloat maxResizeMaxW = self.maxResizeW;
                if (w > maxResizeMaxW) {
                    w = maxResizeMaxW;
                    h = w / _resizeWHScale;
                }
                CGFloat maxResizeMaxH = self.maxResizeH;
                if (h > maxResizeMaxH) {
                    h = maxResizeMaxH;
                    w = h * _resizeWHScale;
                }
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                }
                
                // x轴方向的对立位置不变，所以由x确定w、h
                x = _diagonal.x - w;
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                    w = _diagonal.x - x;
                    h = w / _resizeWHScale;
                }
                
                // 再确定y
                y = _diagonal.y - h * 0.5;
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    y = maxResizeMaxY - h;
                }
            }
            break;
        }
            
        case JPDR_RightMid: {
            if (_isArbitrarily) {
                w += translation.x;
                
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - _diagonal.x;
                }
                
                if (w < _minImageWH) {
                    w = _minImageWH;
                }
            } else {
                w += translation.x;
                h = w / _resizeWHScale;
                
                CGFloat maxResizeMaxW = self.maxResizeW;
                if (w > maxResizeMaxW) {
                    w = maxResizeMaxW;
                    h = w / _resizeWHScale;
                }
                CGFloat maxResizeMaxH = self.maxResizeH;
                if (h > maxResizeMaxH) {
                    h = maxResizeMaxH;
                    w = h * _resizeWHScale;
                }
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                }
                
                // x轴方向的对立位置不变，所以由x确定w、h
                x = _diagonal.x;
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    w = maxResizeMaxX - x;
                    h = w / _resizeWHScale;
                }
                
                // 再确定y
                y = _diagonal.y - h * 0.5;
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    y = maxResizeMaxY - h;
                }
            }
            break;
        }
            
        case JPDR_TopMid: {
            if (_isArbitrarily) {
                y += translation.y;
                
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                }
                
                h = _diagonal.y - y;
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                    y = _diagonal.y - h;
                }
            } else {
                h -= translation.y;
                w = h * _resizeWHScale;
                
                CGFloat maxResizeMaxW = self.maxResizeW;
                if (w > maxResizeMaxW) {
                    w = maxResizeMaxW;
                    h = w / _resizeWHScale;
                }
                CGFloat maxResizeMaxH = self.maxResizeH;
                if (h > maxResizeMaxH) {
                    h = maxResizeMaxH;
                    w = h * _resizeWHScale;
                }
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                }
                
                // y轴方向的对立位置不变，所以由y确定w、h
                y = _diagonal.y - h;
                if (y < self.maxResizeY) {
                    y = self.maxResizeY;
                    h = _diagonal.y - y;
                    w = h * _resizeWHScale;
                }
                
                // 再确定x
                x = _diagonal.x - w * 0.5;
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    x = maxResizeMaxX - w;
                }
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
            }
            break;
        }
            
        case JPDR_BottomMid: {
            if (_isArbitrarily) {
                h += translation.y;
                
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - _diagonal.y;
                }
                
                if (h < _minImageWH) {
                    h = _minImageWH;
                }
            } else {
                h += translation.y;
                w = h * _resizeWHScale;
                
                CGFloat maxResizeMaxW = self.maxResizeW;
                if (w > maxResizeMaxW) {
                    w = maxResizeMaxW;
                    h = w / _resizeWHScale;
                }
                CGFloat maxResizeMaxH = self.maxResizeH;
                if (h > maxResizeMaxH) {
                    h = maxResizeMaxH;
                    w = h * _resizeWHScale;
                }
                if (w < _minImageWH && h < _minImageWH) {
                    if (_resizeWHScale >= 1) {
                        w = _minImageWH;
                        h = w / _resizeWHScale;
                    } else {
                        h = _minImageWH;
                        w = h * _resizeWHScale;
                    }
                }
                
                // y轴方向的对立位置不变，所以由y确定w、h
                y = _diagonal.y;
                CGFloat maxResizeMaxY = CGRectGetMaxY(self.maxResizeFrame);
                if ((y + h) > maxResizeMaxY) {
                    h = maxResizeMaxY - y;
                    w = h * _resizeWHScale;
                }
                
                // 再确定x
                x = _diagonal.x - w * 0.5;
                CGFloat maxResizeMaxX = CGRectGetMaxX(self.maxResizeFrame);
                if ((x + w) > maxResizeMaxX) {
                    x = maxResizeMaxX - w;
                }
                if (x < self.maxResizeX) {
                    x = self.maxResizeX;
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    CGRect imageresizerFrame = CGRectMake(x, y, w, h);
    
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat wZoomScale = 0;
    CGFloat hZoomScale = 0;
    if (w > _startResizeW) {
        wZoomScale = w / _baseImageW;
    }
    if (h > _startResizeH) {
        hZoomScale = h / _baseImageH;
    }
    CGFloat maxZoomScale = MAX(wZoomScale, hZoomScale);
    if (maxZoomScale > zoomScale) {
        zoomScale = maxZoomScale;
    }
    if (zoomScale != self.scrollView.zoomScale) {
        [self.scrollView setZoomScale:zoomScale animated:NO];
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGSize contentSize = self.scrollView.contentSize;
    CGRect convertFrame = [self convertRect:imageresizerFrame toView:self.scrollView];
    if (convertFrame.origin.x < 0) {
        contentOffset.x -= convertFrame.origin.x;
    } else if (CGRectGetMaxX(convertFrame) > contentSize.width) {
        contentOffset.x -= CGRectGetMaxX(convertFrame) - contentSize.width;
    }
    if (convertFrame.origin.y < 0) {
        contentOffset.y -= convertFrame.origin.y;
    } else if (CGRectGetMaxY(convertFrame) > contentSize.height) {
        contentOffset.y -= CGRectGetMaxY(convertFrame) - contentSize.height;
    }
    if (!CGPointEqualToPoint(contentOffset, self.scrollView.contentOffset)) {
        [self.scrollView setContentOffset:contentOffset animated:NO];
    }
    
    self.imageresizerFrame = imageresizerFrame;
}

#pragma mark - super method

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    _currDR = JPDR_Center;
    
    if (!_panGR.enabled) {
        return NO;
    }
    
    CGRect frame = _imageresizerFrame;
    CGFloat scopeWH = _scopeWH;
    CGFloat halfScopeWH = _halfScopeWH;
    
    if (_edgeLineIsEnabled &&
        (!CGRectContainsPoint(CGRectInset(frame, -halfScopeWH, -halfScopeWH), point) ||
         CGRectContainsPoint(CGRectInset(frame, halfScopeWH, halfScopeWH), point))) {
        return NO;
    }
    
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    
    CGRect leftTopRect = CGRectMake(x - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect leftBotRect = CGRectMake(x - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    CGRect rightTopRect = CGRectMake(maxX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
    CGRect rightBotRect = CGRectMake(maxX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
    
    if (!_isRound) {
        if (CGRectContainsPoint(leftTopRect, point)) {
            _currDR = JPDR_LeftTop;
            _diagonal = CGPointMake(maxX, maxY);
        } else if (CGRectContainsPoint(leftBotRect, point)) {
            _currDR = JPDR_LeftBottom;
            _diagonal = CGPointMake(maxX, y);
        } else if (CGRectContainsPoint(rightTopRect, point)) {
            _currDR = JPDR_RightTop;
            _diagonal = CGPointMake(x, maxY);
        } else if (CGRectContainsPoint(rightBotRect, point)) {
            _currDR = JPDR_RightBottom;
            _diagonal = CGPointMake(x, y);
        }
    }
    
    if (_currDR == JPDR_Center) {
        CGRect leftMidRect = CGRectNull;
        CGRect rightMidRect = CGRectNull;
        CGRect topMidRect = CGRectNull;
        CGRect botMidRect = CGRectNull;
        CGFloat midX = CGRectGetMidX(frame);
        CGFloat midY = CGRectGetMidY(frame);
        
        if (_edgeLineIsEnabled && !_isRound) {
            leftMidRect = CGRectMake(x - halfScopeWH, y + halfScopeWH, scopeWH, h - scopeWH);
            rightMidRect = CGRectMake(maxX - halfScopeWH, y + halfScopeWH, scopeWH, h - scopeWH);
            topMidRect = CGRectMake(x + halfScopeWH, y - halfScopeWH, w - scopeWH, scopeWH);
            botMidRect = CGRectMake(x + halfScopeWH, maxY - halfScopeWH, w - scopeWH, scopeWH);
        } else if (_isShowMidDots || _isRound) {
            leftMidRect = CGRectMake(x - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
            rightMidRect = CGRectMake(maxX - halfScopeWH, midY - halfScopeWH, scopeWH, scopeWH);
            topMidRect = CGRectMake(midX - halfScopeWH, y - halfScopeWH, scopeWH, scopeWH);
            botMidRect = CGRectMake(midX - halfScopeWH, maxY - halfScopeWH, scopeWH, scopeWH);
        }
        
        if (CGRectContainsPoint(leftMidRect, point)) {
            _currDR = JPDR_LeftMid;
            _diagonal = CGPointMake(maxX, midY);
        } else if (CGRectContainsPoint(rightMidRect, point)) {
            _currDR = JPDR_RightMid;
            _diagonal = CGPointMake(x, midY);
        } else if (CGRectContainsPoint(topMidRect, point)) {
            _currDR = JPDR_TopMid;
            _diagonal = CGPointMake(midX, maxY);
        } else if (CGRectContainsPoint(botMidRect, point)) {
            _currDR = JPDR_BottomMid;
            _diagonal = CGPointMake(midX, y);
        } else {
            return NO;
        }
    }
    
    _startResizeW = w;
    _startResizeH = h;
    return YES;
}

@end

@implementation JPImageresizerProxy
+ (instancetype)proxyWithTarget:(id)target {
    JPImageresizerProxy *proxy = [self alloc];
    proxy.target = target;
    return proxy;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end
