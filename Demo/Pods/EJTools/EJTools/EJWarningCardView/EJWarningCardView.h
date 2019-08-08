//
//  EJWarningCardView.h
//  IOSParents
//
//  Created by Lius on 2017/5/22.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EJWarningCardView;

typedef NS_ENUM(NSUInteger, WarningCardShowFromType) {
    WarningCardShowFromRightBottom,
    WarningCardShowFromRightTop,
    WarningCardShowFromBottomCenter,
    WarningCardShowFromTopCenter,
    WarningCardShowFromLeftTop,
    WarningCardShowFromLeftBottom
};

@protocol EJWarningCardViewDelegate <NSObject>
@optional
- (void)ejwarningCardView:(EJWarningCardView *)warningView ClickButtonAtIndex:(NSInteger)index;

- (void)ejwarningCardViewHide;

@end

typedef enum : NSUInteger {
    WarningCardCellTypeOnlyTitle,
    WarningCardCellTypeLeftImg,
    WarningCardCellTypeRightImg,
} WarningCardCellType;

@interface EJWarningCardCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView * img;

@property (nonatomic, strong) UIView * bottomLine;

@property (nonatomic, assign) WarningCardCellType type;

- (void)setType:(WarningCardCellType)type Img:(UIImage *)image cellSize:(CGSize)size;

@end

@interface EJWarningCardView : UIView

- (instancetype)initWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray AtPoint:(CGPoint)point AndSize:(CGSize)size delegate:(id<EJWarningCardViewDelegate>)delegate
__deprecated_msg("Method deprecated. Use [initWithTitleArray: imageArray: AtPoint: AndSize: EdgeInset: delegate:]");

- (instancetype)initWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray AtPoint:(CGPoint)point AndSize:(CGSize)size EdgeInset:(UIEdgeInsets)edgeInset delegate:(id<EJWarningCardViewDelegate>)delegate;

- (void)show;

- (void)showInView:(UIView *)view;

- (void)hide;

@property (nonatomic, weak) id <EJWarningCardViewDelegate> delegate;

@property (nonatomic, strong) NSIndexPath * indexPath;

@property (nonatomic, assign) UITableViewCellSeparatorStyle separatorStyle;

@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, strong) UIColor * separatorColor;

@property (nonatomic, assign) UIEdgeInsets separatorInset;

@property (nonatomic, assign) UIEdgeInsets edgeInset;

@property (nonatomic, assign) WarningCardShowFromType showFrom;

@property (nonatomic, assign) WarningCardCellType type;

@property (nonatomic, strong) UIImage *selectedImg;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIImage *backgroundImg;

@property (nonatomic, assign) BOOL isShowBg;

@property (nonatomic, assign) BOOL scrollEnable;

/**
 点击 cell 后 是否自动隐藏 WarningCardView. default is YES;
 */
@property (nonatomic, assign) BOOL autoHidden;

/**
 cell 中的 内容 距左的 距离。默认是 16
 */
@property (nonatomic, assign) CGFloat contentLeft;

@end
