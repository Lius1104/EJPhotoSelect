//
//  EJEmptyPage.m
//  LighterController
//
//  Created by Lius on 2017/6/21.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import "EJEmptyPage.h"
//#import "UIImage+Expand.h"
#import <LSToolsKit/UIImage+LSAdd.h>
#import <YYKit/UIColor+YYAdd.h>

@interface EJEmptyPage ()

@property (nonatomic, assign) EPDefaultColor defaultColors;
@property (nonatomic, assign) EPDefaultImage defaultImages;

@end

@implementation EJEmptyPage

+ (void)configDefaultColor:(EPDefaultColor)defaultColor {
    NSMutableDictionary * dicColors = [NSMutableDictionary dictionary];
    if ([defaultColor.titleColor length]) {
        dicColors[@"titleColor"] = defaultColor.titleColor;
    }
    if ([defaultColor.desColor length]) {
        dicColors[@"desColor"] = defaultColor.desColor;
    }
    if ([defaultColor.buttonColor length]) {
        dicColors[@"buttonColor"] = defaultColor.buttonColor;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dicColors forKey:@"EPDefaultColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)configDefaultImage:(EPDefaultImage)defaultImage {
    NSMutableDictionary * dicImages = [NSMutableDictionary dictionary];
    if ([defaultImage.noContentImgName length] > 0) {
        dicImages[@"noContentImgName"] = defaultImage.noContentImgName;
    }
    if ([defaultImage.editImgName length] > 0) {
        dicImages[@"editImgName"] = defaultImage.editImgName;
    }
    [[NSUserDefaults standardUserDefaults] setObject:dicImages forKey:@"EPDefaultImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)initWithMainView:(UIScrollView *)mainView {
    self = [super init];
    if (self) {
        self.pageType = EmptyPageTypeOfNoContent;
        _verticalOffset = 0;
        _spaceHeight = 11;
        self.mainView = mainView;
        [self configDefaults];
        
    }
    return self;
}

- (void)configDefaults {
    NSDictionary * dicColors = [[NSUserDefaults standardUserDefaults] objectForKey:@"EPDefaultColor"];
    for (NSString * key in dicColors.allKeys) {
        if ([key isEqualToString:@"titleColor"]) {
            _defaultColors.titleColor = dicColors[key];
        }
        if ([key isEqualToString:@"desColor"]) {
            _defaultColors.desColor = dicColors[key];
        }
        if ([key isEqualToString:@"buttonColor"]) {
            _defaultColors.buttonColor = dicColors[key];
        }
    }
    
    NSDictionary * dicImages = [[NSUserDefaults standardUserDefaults] objectForKey:@"EPDefaultImage"];
    for (NSString * key in dicImages.allKeys) {
        if ([key isEqualToString:@"noContentImgName"]) {
            _defaultImages.noContentImgName = dicImages[key];
        }
        if ([key isEqualToString:@"editImgName"]) {
            _defaultImages.editImgName = dicImages[key];
        }
    }
}

- (void)setMainView:(UIScrollView *)mainView {
    if ([mainView isKindOfClass:[UIScrollView class]] || [mainView isKindOfClass:[UITableView class]] || [mainView isKindOfClass:[UICollectionView class]]) {
        _mainView = mainView;
        _mainView.emptyDataSetSource = self;
        _mainView.emptyDataSetDelegate = self;
    }
}

- (void)reloadEmptyPage {
    if (self.delegate != nil && ([self.delegate isKindOfClass:[UIScrollView class]] || [self.delegate isKindOfClass:[UITableView class]] || [self.delegate isKindOfClass:[UICollectionView class]])) {
        [(UIScrollView *)self.delegate reloadEmptyDataSet];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = nil;
    UIFont *font = [UIFont systemFontOfSize:16];

    UIColor * textColor;
    if (_titleColor) {
        textColor = _titleColor;
    } else {
        textColor = [_defaultColors.titleColor length] ? [UIColor colorWithHexString:_defaultColors.titleColor] : [UIColor blackColor];
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    switch (_pageType) {
        case EmptyPageTypeOfNoContent: {
            text = @"~ 空空如也 ~";
            font = _titleFont == nil ? font : _titleFont;
        }
            break;
        case EmptyPageTypeOfCustom: {
            text = _title;
            font = _titleFont == nil ? font : _titleFont;
        }
            break;
        case EmptyPageTypeOfNoContentToEdit: {
            text = @"~ 空空如也 ~";
            font = _titleFont == nil ? font : _titleFont;
        }
            break;
        case EmptyPageTypeOfNotShow: {
            text = @"";
        }
            break;
    }
    if ([text length] == 0) {
        return nil;
    }
    
    if (font) {
        [attributes setObject:font forKey:NSFontAttributeName];
    }
    
    if (textColor) {
        [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = nil;
    UIFont *font = [UIFont systemFontOfSize:16];
    UIColor * textColor;
    if (_desColor) {
        textColor = _desColor;
    } else {
        textColor = [_defaultColors.desColor length] ? [UIColor colorWithHexString:_defaultColors.desColor] : [UIColor lightGrayColor];
    }
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    switch (_pageType) {
        case EmptyPageTypeOfNoContent: {
            text = @"";
            font = _desFont == nil ? font : _desFont;
        }
            break;
        case EmptyPageTypeOfCustom: {
            text = _descriptionTitle;
            font =  _desFont == nil ? font : _desFont;
        }
            break;
        case EmptyPageTypeOfNoContentToEdit: {
            text = @"赶快新建一个吧";
            font = _desFont == nil ? font : _desFont;
        }
            break;
        case EmptyPageTypeOfNotShow: {
            text = @"";
        }
            break;
    }
    if ([text length] == 0) {
        return nil;
    }
    
    if (font) {
        [attributes setObject:font forKey:NSFontAttributeName];
    }
    
    if (textColor) {
        [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    UIImage *img = nil;
    switch (_pageType) {
        case EmptyPageTypeOfNoContent: {
            if ([_defaultImages.noContentImgName length]) {
                img = [UIImage imageNamed:_defaultImages.noContentImgName];
            }
            if (_imgSize.width == 0 || _imgSize.height == 0) {
            } else {
                img = [img imageByScalingToSize:_imgSize];
            }
        }
            break;
        case EmptyPageTypeOfCustom: {
            if (_imgSize.width == 0 || _imgSize.height == 0) {
                img = _image;
            } else {
                img = [_image imageByScalingToSize:_imgSize];
            }
        }
            break;
        case EmptyPageTypeOfNoContentToEdit: {
            if ([_defaultImages.editImgName length]) {
                img = [UIImage imageNamed:_defaultImages.editImgName];
            }
            if (_imgSize.width == 0 || _imgSize.height == 0) {
            } else {
                img = [img imageByScalingToSize:_imgSize];
            }
        }
            break;
        case EmptyPageTypeOfNotShow: {
            img = nil;
        }
            break;
    }
    
    return img;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return _verticalOffset;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return _spaceHeight;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    if (_pageType == EmptyPageTypeOfNotShow) {
        return nil;
    }
    if ([_buttonTitle length] == 0) {
        return nil;
    }
    if (_buttonColor == nil) {
        _buttonColor = [_defaultColors.buttonColor length] ? [UIColor colorWithHexString:_defaultColors.buttonColor] : [UIColor blueColor];
    }
    if (_buttonFont == nil) {
        _buttonFont = [UIFont systemFontOfSize:15];
    }
    NSAttributedString * attStr = [[NSAttributedString alloc] initWithString:_buttonTitle attributes:@{NSFontAttributeName : _buttonFont, NSForegroundColorAttributeName : _buttonColor}];
    return attStr;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(ej_emptyPage:clickView:)]) {
        [self.delegate ej_emptyPage:self clickView:view];
    }
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(ej_emptyPage:clickButton:)]) {
        [self.delegate ej_emptyPage:self clickButton:button];
    }
}

@end
