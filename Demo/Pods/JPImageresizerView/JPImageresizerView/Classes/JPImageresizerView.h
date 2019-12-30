//
//  JPImageresizerView.h
//  JPImageresizerView
//
//  Created by 周健平 on 2017/12/19.
//  Copyright © 2017年 周健平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPImageresizerConfigure.h"
#import "JPImageresizerFrameView.h"

@interface JPImageresizerView : UIView

/**
 * 层级结构
    - JPImageresizerView（self）
        - scrollView
            - imageView（裁剪的imageView）
        - frameView（绘制裁剪边框的view）
 * scrollView与frameView的frame一致
 */
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) JPImageresizerFrameView *frameView;

/*!
 @method
 @brief 类方法（推荐）
 @param configure --- 包含了所有初始化参数
 @discussion 使用JPImageresizerConfigure配置好参数
 */
+ (instancetype)imageresizerViewWithConfigure:(JPImageresizerConfigure *)configure
                    imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
                 imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/*!
 @method
 @brief 工厂方法
 @param resizeImage --- 裁剪图片
 @param frame --- 相对父视图的区域
 @param frameType --- 边框样式
 @param animationCurve --- 动画曲线
 @param blurEffect --- 模糊效果
 @param bgColor --- 背景颜色
 @param maskAlpha --- 遮罩颜色的透明度（背景颜色 * 透明度）
 @param strokeColor ---裁剪线颜色
 @param verBaseMargin --- 裁剪图片与裁剪区域的垂直间距
 @param horBaseMargin --- 裁剪图片与裁剪区域的水平间距
 @param resizeWHScale --- 裁剪宽高比
 @param contentInsets --- 裁剪区域与主视图的内边距，目前初始化后不可再更改
 @param borderImage --- 边框图片（若为nil则使用frameType的边框）
 @param borderImageRectInset --- 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距）
 @param maximumZoomScale --- 最大缩放比例
 @param isRoundResize --- 是否初始化圆切（若为YES则resizeWHScale为1）
 @param isShowMidDots --- 是否显示中间的4个点（上、下、左、右的中点）
 @param imageresizerIsCanRecovery --- 是否可以重置的回调（当裁剪区域缩放至适应范围后就会触发该回调）
 @param imageresizerIsPrepareToScale --- 是否预备缩放裁剪区域至适应范围（当裁剪区域发生变化的开始和结束就会触发该回调）
 @discussion 自行配置参数
 */
- (instancetype)initWithResizeImage:(UIImage *)resizeImage
                              frame:(CGRect)frame
                          frameType:(JPImageresizerFrameType)frameType
                     animationCurve:(JPAnimationCurve)animationCurve
                         blurEffect:(UIBlurEffect *)blurEffect
                            bgColor:(UIColor *)bgColor
                          maskAlpha:(CGFloat)maskAlpha
                        strokeColor:(UIColor *)strokeColor
                      verBaseMargin:(CGFloat)verBaseMargin
                      horBaseMargin:(CGFloat)horBaseMargin
                      resizeWHScale:(CGFloat)resizeWHScale
                      contentInsets:(UIEdgeInsets)contentInsets
                        borderImage:(UIImage *)borderImage
               borderImageRectInset:(CGPoint)borderImageRectInset
                   maximumZoomScale:(CGFloat)maximumZoomScale
                      isRoundResize:(BOOL)isRoundResize
                      isShowMidDots:(BOOL)isShowMidDots
          imageresizerIsCanRecovery:(JPImageresizerIsCanRecoveryBlock)imageresizerIsCanRecovery
       imageresizerIsPrepareToScale:(JPImageresizerIsPrepareToScaleBlock)imageresizerIsPrepareToScale;

/** 边框样式 */
@property (nonatomic) JPImageresizerFrameType frameType;

/** 动画曲线（默认是线性Linear） */
@property (nonatomic, assign) JPAnimationCurve animationCurve;

/**
 * 裁剪的图片
 * 设置该值会调用 -setResizeImage: animated: transition: 方法（isAnimated = YES，transition = UIViewAnimationTransitionCurlUp）
 */
@property (nonatomic) UIImage *resizeImage;

/**
 * 模糊效果
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIBlurEffect *blurEffect;

/**
 * 背景颜色
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIColor *bgColor;

/**
 * 遮罩颜色的透明度（背景颜色 * 透明度）
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) CGFloat maskAlpha;

/**
 * 裁剪线颜色
 * 设置该值会调用 -setupStrokeColor: blurEffect: bgColor: maskAlpha: animated: 方法（其他参数为当前值，isAnimated = YES）
 */
@property (nonatomic) UIColor *strokeColor;

/**
 * 裁剪宽高比（0则为任意比例）
 * 设置该值会调用 -setResizeWHScale: isToBeArbitrarily: animated: 方法（isToBeArbitrarily = NO，isAnimated = YES）
 */
@property (nonatomic) CGFloat resizeWHScale;

/**
 * 初始裁剪宽高比（默认为初始化时的resizeWHScalem）
 * 调用 -recoveryByInitialResizeWHScale 方法进行重置则 resizeWHScale 会重置为该属性的值
 */
@property (nonatomic) CGFloat initialResizeWHScale;

/** 裁剪框当前的宽高比 */
@property (readonly) CGFloat imageresizeWHScale;

/** 裁剪框边线能否进行对边拖拽（当裁剪宽高比为0，即任意比例时才有效，默认为yes） */
@property (nonatomic, assign) BOOL edgeLineIsEnabled;

/** 裁剪图片与裁剪区域的垂直边距 */
@property (nonatomic, assign) CGFloat verBaseMargin;

/** 裁剪图片与裁剪区域的水平边距 */
@property (nonatomic, assign) CGFloat horBaseMargin;

/** 是否顺时针旋转（默认逆时针） */
@property (nonatomic, assign) BOOL isClockwiseRotation;

/** 是否锁定裁剪区域（锁定后无法拖动裁剪区域） */
@property (nonatomic) BOOL isLockResizeFrame;

/**
 * 垂直镜像（沿着Y轴旋转180）
 * 设置该值会调用 -setVerticalityMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL verticalityMirror;

/**
 * 水平镜像（沿着X轴旋转180）
 * 设置该值会调用 -setHorizontalMirror: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL horizontalMirror;

/**
 * 预览模式（隐藏边框，停止拖拽操作，用于预览裁剪后的区域）
 * 设置该值会调用 -setIsPreview: animated: 方法（isAnimated = YES）
 */
@property (nonatomic, assign) BOOL isPreview;

/** 边框图片（若为nil则使用frameType的边框） */
@property (nonatomic) UIImage *borderImage;

/** 边框图片与边线的偏移量（即CGRectInset，用于调整边框图片与边线的差距） */
@property (nonatomic) CGPoint borderImageRectInset;

/** 是否显示中间的4个点（上、下、左、右的中点） */
@property (nonatomic) BOOL isShowMidDots;

/*!
 @method
 @brief 更换裁剪的图片
 @param resizeImage --- 裁剪的图片
 @param transition --- 切换效果（isAnimated为YES才生效，若为UIViewAnimationTransitionNone则由淡入淡出效果代替）
 @param isAnimated --- 是否带动画效果
 @discussion 更换裁剪的图片，裁剪宽高比会重置
 */
- (void)setResizeImage:(UIImage *)resizeImage animated:(BOOL)isAnimated transition:(UIViewAnimationTransition)transition;

/*!
 @method
 @brief 设置颜色
 @param strokeColor --- 裁剪线颜色
 @param blurEffect --- 模糊效果
 @param bgColor --- 背景颜色
 @param maskAlpha --- 遮罩颜色的透明度（背景颜色 * 透明度）
 @param isAnimated --- 是否带动画效果
 @discussion 同时修改UI元素
 */
- (void)setupStrokeColor:(UIColor *)strokeColor
              blurEffect:(UIBlurEffect *)blurEffect
                 bgColor:(UIColor *)bgColor
               maskAlpha:(CGFloat)maskAlpha
                animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置裁剪宽高比
 @param resizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 设置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @param isAnimated --- 是否带动画效果
 @discussion 以最合适的尺寸更新裁剪框的尺寸（0则为任意比例）
 */
- (void)setResizeWHScale:(CGFloat)resizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily animated:(BOOL)isAnimated;

/*!
 @method
 @brief 圆切
 @param isAnimated --- 是否带动画效果
 @discussion 以圆形裁剪，此状态下边框图片会隐藏，并且宽高比是1:1，恢复矩形则重设resizeWHScale
 */
- (void)roundResize:(BOOL)isAnimated;

/*!
 @method
 @brief 是否正在圆切
 @return YES：圆切，NO：矩形
 */
- (BOOL)isRoundResizing;

/*!
 @method
 @brief 设置是否垂直镜像
 @param verticalityMirror --- 是否垂直镜像
 @param isAnimated --- 是否带动画效果
 @discussion 垂直镜像，沿着Y轴旋转180°
 */
- (void)setVerticalityMirror:(BOOL)verticalityMirror animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置是否水平镜像
 @param horizontalMirror --- 是否水平镜像
 @param isAnimated --- 是否带动画效果
 @discussion 水平镜像，沿着X轴旋转180°
 */
- (void)setHorizontalMirror:(BOOL)horizontalMirror animated:(BOOL)isAnimated;

/*!
 @method
 @brief 设置是否预览
 @param isPreview --- 是否预览
 @param isAnimated --- 是否带动画效果
 @discussion 隐藏边框，停止拖拽操作，用于预览裁剪后的区域
 */
- (void)setIsPreview:(BOOL)isPreview animated:(BOOL)isAnimated;

/*!
 @method
 @brief 同时更新图片、垂直边距和水平边距
 @discussion 同步更新
 */
- (void)updateResizeImage:(UIImage *)resizeImage verBaseMargin:(CGFloat)verBaseMargin horBaseMargin:(CGFloat)horBaseMargin;

/*!
 @method
 @brief 旋转图片
 @discussion 旋转90度，支持4个方向，分别是垂直向上、水平向左、垂直向下、水平向右
 */
- (void)rotation;

/*!
 @method
 @brief 按当前裁剪宽高比（resizeWHScale）进行重置
 @discussion 回到最初状态，resizeWHScale 不会被重置
 */
- (void)recoveryByCurrentResizeWHScale;

/*!
 @method
 @brief 重置回圆切状态
 @discussion 以圆切状态回到最初状态
 */
- (void)recoveryToRoundResize;

/*!
 @method
 @brief 按初始裁剪宽高比（initialResizeWHScale）进行重置
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale =  initialResizeWHScale
 */
- (void)recoveryByInitialResizeWHScale:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 按目标裁剪宽高比进行重置
 @param targetResizeWHScale --- 目标裁剪宽高比
 @param isToBeArbitrarily --- 重置之后 resizeWHScale 是否为任意比例（若为YES，最后 resizeWHScale = 0）
 @discussion 回到最初状态，若 isToBeArbitrarily 为 NO，则重置之后 resizeWHScale  = targetResizeWHScale
 */
- (void)recoveryByTargetResizeWHScale:(CGFloat)targetResizeWHScale isToBeArbitrarily:(BOOL)isToBeArbitrarily;

/*!
 @method
 @brief 原图尺寸裁剪
 @param complete --- 裁剪完成的回调
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)originImageresizerWithComplete:(void(^)(UIImage *resizeImage))complete;

/*!
 @method
 @brief 压缩尺寸裁剪
 @param complete --- 裁剪完成的回调
 @param compressScale --- 压缩比例，大于等于1按原图尺寸裁剪，小于等于0则返回nil（例：compressScale = 0.5，1000 x 500 --> 500 x 250）
 @discussion 裁剪过程在子线程，回调已切回到主线程，可调用该方法前加上状态提示
 */
- (void)imageresizerWithComplete:(void(^)(UIImage *resizeImage))complete compressScale:(CGFloat)compressScale;

@end
