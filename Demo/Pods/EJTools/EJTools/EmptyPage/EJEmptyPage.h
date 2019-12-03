//
//  EJEmptyPage.h
//  LighterController
//
//  Created by Lius on 2017/6/21.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@class EJEmptyPage;
typedef enum : NSUInteger {
    EmptyPageTypeOfNoContent, //没有内容
    EmptyPageTypeOfNoContentToEdit,// 没有内容 去编辑 带 button
    EmptyPageTypeOfCustom,// 自定义 需要自行配置
    EmptyPageTypeOfNotShow,// 不显示
} EJEmptyPageType;

@protocol EJEmptyPageDelegate <NSObject>
@optional
- (void)ej_emptyPage:(EJEmptyPage *)emptyPage clickView:(UIView *)tapView;

- (void)ej_emptyPage:(EJEmptyPage *)emptyPage clickButton:(UIButton *)button;

@end

struct EPDefaultColor {
    NSString * titleColor;
    NSString * desColor;
    NSString * buttonColor;
};
typedef struct EPDefaultColor EPDefaultColor;

/**
 EJDefaultColor的初始化方法

 @param titleColorHex 标题的默认颜色 例如，#ffffff 不配置默认使用黑色
 @param desColorHex 描述的默认颜色 例如，#ffffff 不配置默认使用灰色
 @param buttonColorHex 按钮的默认颜色 例如，#ffffff 不配置默认使用蓝色
 @return EPDefaultColor
 */
CG_INLINE EPDefaultColor
EPDefaultColorMake(NSString * titleColorHex, NSString * desColorHex, NSString * buttonColorHex) {
    EPDefaultColor defaultColors;
    if (![titleColorHex hasPrefix:@"#"]) {
        titleColorHex = [NSString stringWithFormat:@"#%@", titleColorHex];
    }
    if (![desColorHex hasPrefix:@"#"]) {
        desColorHex = [NSString stringWithFormat:@"#%@", desColorHex];
    }
    if (![buttonColorHex hasPrefix:@"#"]) {
        buttonColorHex = [NSString stringWithFormat:@"#%@", buttonColorHex];
    }
    defaultColors.titleColor = [titleColorHex length] ? titleColorHex : @"#000000";
    defaultColors.desColor = [desColorHex length] ? desColorHex : @"#AAAAAA";
    defaultColors.buttonColor = [buttonColorHex length] ? buttonColorHex : @"#0000FF";
    return defaultColors;
}

struct EPDefaultImage {
    NSString * noContentImgName;
    NSString * editImgName;
};
typedef struct EPDefaultImage EPDefaultImage;

CG_INLINE EPDefaultImage
EPDefaultImageMake(NSString * noContentImgName, NSString * editImgName) {
    EPDefaultImage defaultImage;
    defaultImage.noContentImgName = noContentImgName;
    defaultImage.editImgName = editImgName;
    return defaultImage;
}


@interface EJEmptyPage : NSObject<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/**
 * 空页面类型
 * 如果需要配置 不同类型的 空页面 的默认值，需要#define以下：
 * EmptyPageTypeOfNoContent => kEPNoContentImageName
 * EmptyPageTypeOfNoContentToEdit => kEPEditImageName
 *
 */
@property (nonatomic, assign) EJEmptyPageType pageType;

@property (nonatomic, weak) id <EJEmptyPageDelegate> delegate;

@property (nonatomic, weak) UIScrollView * mainView;

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) CGSize imgSize;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) UIFont * titleFont;
@property (nonatomic, strong) UIColor * titleColor;

@property (nonatomic, strong) NSAttributedString * titleAttString;


//EmptyPageTypeOfCustom 状态下使用
@property (nonatomic, copy) NSString * descriptionTitle;
@property (nonatomic, strong) UIFont * desFont;
@property (nonatomic, strong) UIColor * desColor;

@property (nonatomic, strong) NSAttributedString * desAttString;


@property (nonatomic, copy) NSString * buttonTitle;
@property (nonatomic, strong) UIColor * buttonColor;
@property (nonatomic, strong) UIFont * buttonFont;

@property (nonatomic, strong) NSAttributedString * buttonAttString;


@property (nonatomic, assign) CGFloat verticalOffset;

@property (nonatomic, assign) CGFloat spaceHeight;


/**
 全局配置 空页面的默认颜色

 @param defaultColor struct EPDefaultColor
 */
+ (void)configDefaultColor:(EPDefaultColor)defaultColor;

/**
 全局配置 空页面的默认图片

 @param defaultImage struct EPDefaultImage
 */
+ (void)configDefaultImage:(EPDefaultImage)defaultImage;

/**
 初始化方法，默认初始化空页面类型是EmptyPageTypeOfNoContent

 @param mainView 需要设置空页面的scrollView
 @return EJEmptyPage
 */
- (instancetype)initWithMainView:(UIScrollView *)mainView;

/**
 调整空页面类型后，调用该方法，刷新空页面，一般在点击操作完成产生
 */
- (void)reloadEmptyPage;

@end
