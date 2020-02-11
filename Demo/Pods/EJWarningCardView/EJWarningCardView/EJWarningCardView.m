//
//  EJWarningCardView.m
//  IOSParents
//
//  Created by Lius on 2017/5/22.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "EJWarningCardView.h"

@implementation EJWarningCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLab];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)setType:(WarningCardCellType)type Img:(UIImage *)image cellSize:(CGSize)size contentLeft:(CGFloat)contentLeft contentRight:(CGFloat)contentRight selectedImageSpace:(CGFloat)selectedImageSpace {
    _type = type;
    switch (type) {
        case WarningCardCellTypeOnlyTitle: {
            _titleLab.frame = CGRectMake(contentLeft, 0, size.width - contentLeft * 2, size.height);
        }
            break;
        case WarningCardCellTypeLeftImg: {
            _img = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_img];
            CGRect imgRect = _img.frame;
            imgRect.origin.x = contentLeft;
            imgRect.origin.y = (size.height - imgRect.size.height) / 2.f;
            _img.frame = imgRect;

            CGRect titleRect = _titleLab.frame;
            titleRect.origin.x = CGRectGetMaxX(imgRect) + selectedImageSpace;
            titleRect.size.width = size.width - titleRect.origin.x - contentRight;
            titleRect.size.height = size.height;
            _titleLab.frame = titleRect;
        }
            break;
        case WarningCardCellTypeRightImg: {
            _img = [[UIImageView alloc] initWithImage:image];
            [self addSubview:_img];

            CGRect imgRect = _img.frame;
            imgRect.origin.x = size.width - contentRight - CGRectGetWidth(imgRect);
            imgRect.origin.y = (size.height - imgRect.size.height) / 2.f;
            _img.frame = imgRect;
            
            CGRect titleRect = _titleLab.frame;
            titleRect.origin.x = contentLeft;
            titleRect.size.width = CGRectGetMinX(imgRect) - selectedImageSpace - CGRectGetMinX(titleRect);
            titleRect.size.height = size.height;
            _titleLab.frame = titleRect;
        }
            break;
        default:
            break;
    }
}

@end

@interface EJWarningCardView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView * mainView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSArray *imageArray;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, assign) CGSize size;

@end

@implementation EJWarningCardView

#define kAnimationDuration      0.35

- (instancetype)initWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray AtPoint:(CGPoint)point AndSize:(CGSize)size EdgeInset:(UIEdgeInsets)edgeInset delegate:(id<EJWarningCardViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBackground)];
        [self addGestureRecognizer:tap];
        
        _autoHidden = YES;
        _contentLeft = 16;
        _contentRight = 16;
        _selectedImageSpace = 8;
        
        _titleArray = [titleArray mutableCopy];
        _imageArray = [imageArray mutableCopy];
        _point = point;
        _size = size;
        _edgeInset = edgeInset;
        _delegate = delegate;
        _textAlignment = NSTextAlignmentLeft;
        _isShowBg = YES;
        _separatorStyle = UITableViewCellSeparatorStyleNone;
        _selectionStyle = UITableViewCellSelectionStyleNone;
        _titleFont = [UIFont systemFontOfSize:15];
        _textColor = [UIColor blackColor];
        
        CGFloat height = size.height - edgeInset.top - edgeInset.bottom;
        _cellHeight = height / [_titleArray count];
        
        self.mainView.alpha = 0;
    }
    return self;
}

- (instancetype)initWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray AtPoint:(CGPoint)point AndSize:(CGSize)size delegate:(id<EJWarningCardViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBackground)];
        [self addGestureRecognizer:tap];
        
        _autoHidden = YES;
        _contentLeft = 16;
        _contentRight = 16;
        _selectedImageSpace = 8;
        
        _titleArray = [titleArray mutableCopy];
        _imageArray = [imageArray mutableCopy];
        _point = point;
        _size = size;
        _edgeInset = UIEdgeInsetsMake(-1, -1, 1, -1);
        _delegate = delegate;
        _textAlignment = NSTextAlignmentLeft;
        _isShowBg = YES;
        _separatorStyle = UITableViewCellSeparatorStyleNone;
        _selectionStyle = UITableViewCellSelectionStyleNone;
        _titleFont = [UIFont systemFontOfSize:15];
        _textColor = [UIColor blackColor];
        
        _cellHeight = _size.height / [_titleArray count];
        
        self.mainView.alpha = 0;
    }
    return self;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
    _separatorStyle = separatorStyle;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset {
    _separatorInset = separatorInset;
    _tableView.separatorInset = _separatorInset;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
//    _tableView.separatorColor = _separatorColor;
}

- (void)setEdgeInset:(UIEdgeInsets)edgeInset {
    _edgeInset = edgeInset;
    CGFloat totalHeight = _size.height;
//    if (_edgeInset.top >= 0) {
        totalHeight = totalHeight - _edgeInset.top;
//    }
//    if (_edgeInset.bottom <= 0) {
//        totalHeight -= -_edgeInset.bottom;
//    } else {
        totalHeight -= _edgeInset.bottom;
//    }
    _cellHeight = totalHeight / [_titleArray count];
}

- (void)setShowFrom:(WarningCardShowFromType)showFrom {
    _showFrom = showFrom;
    
    CGRect tableFrame = _tableView.frame;
    tableFrame.origin.x = _edgeInset.left;
    tableFrame.origin.y = _edgeInset.top;
    tableFrame.size.width = _size.width - _edgeInset.left - _edgeInset.right;
    tableFrame.size.height = _size.height - _edgeInset.top - _edgeInset.bottom;
    _tableView.frame = tableFrame;
    
    CGRect mainFrame = _mainView.frame;
    
    switch (_showFrom) {
        case WarningCardShowFromRightTop: {
            mainFrame.origin.y = _point.y;
            _mainView.frame = mainFrame;
            _mainView.layer.anchorPoint = CGPointMake(1, 0);
            _mainView.layer.position = CGPointMake(_point.x, _point.y);
        }
            break;
        case WarningCardShowFromRightBottom: {
            mainFrame.origin.y = _point.y - CGRectGetHeight(mainFrame);
            _mainView.frame = mainFrame;
            
            _mainView.layer.anchorPoint = CGPointMake(1, 1);
            _mainView.layer.position = CGPointMake(_point.x, _point.y);
        }
            break;
        case WarningCardShowFromBottomCenter: {
            mainFrame.origin.y = _point.y - CGRectGetHeight(mainFrame);
            _mainView.frame = mainFrame;
            
            _mainView.layer.anchorPoint = CGPointMake(0.5, 1);
            _mainView.layer.position = CGPointMake(_point.x, _point.y - 5);
        }
            break;
        case WarningCardShowFromTopCenter: {
            mainFrame.origin.y = _point.y - CGRectGetHeight(mainFrame);
            _mainView.frame = mainFrame;
            
            _mainView.layer.anchorPoint = CGPointMake(0.5, 0);
            _mainView.layer.position = CGPointMake(_point.x, _point.y);
        }
            break;
        case WarningCardShowFromLeftTop: {
            mainFrame.origin.y = _point.y;
            _mainView.frame = mainFrame;
            
            _mainView.layer.anchorPoint = CGPointMake(0, 0);
            _mainView.layer.position = CGPointMake(_point.x, _point.y);
        }
            break;
        case WarningCardShowFromLeftBottom: {
            mainFrame.origin.y = _point.y - CGRectGetHeight(mainFrame);
            _mainView.frame = mainFrame;
            
            _mainView.layer.anchorPoint = CGPointMake(0, 1);
            _mainView.layer.position = CGPointMake(_point.x, _point.y);
        }
            break;
        default:
            break;
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    [_tableView reloadData];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [_tableView reloadData];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_tableView reloadData];
}

- (void)setType:(WarningCardCellType)type {
    _type = type;
    [_tableView reloadData];
}

- (void)setBackgroundImg:(UIImage *)backgroundImg {
//    _mainView.layer.contents = (__bridge id)backgroundImg.CGImage;
    _backgroundImg = backgroundImg;
    _mainView.image = _backgroundImg;
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _tableView.scrollEnabled = scrollEnable;
}

- (void)setContentLeft:(CGFloat)contentLeft {
    if (_contentLeft == _contentRight) {
        _contentRight = contentLeft;
    }
    _contentLeft = contentLeft;
    
    [_tableView reloadData];
}

- (void)setSelectedImageSpace:(CGFloat)selectedImageSpace {
    _selectedImageSpace = selectedImageSpace;
    [_tableView reloadData];
}

- (void)show {
    UIWindow * window;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
//        NSLog(@"have");
        window = [[[UIApplication sharedApplication] delegate] window];
    } else {
//        NSLog(@"did not ");
        if (@available(iOS 11.0, *)) {
            window = [[UIApplication sharedApplication].windows firstObject];
        } else {
            window = [[UIApplication sharedApplication].windows lastObject];
        }
    }
    self.mainView.alpha = 1;
    if (_showFrom == WarningCardShowFromTopCenter || _showFrom == WarningCardShowFromBottomCenter) {
        _mainView.transform = CGAffineTransformMakeScale(1.0, 0.00001);
    } else {
        _mainView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }
    self.frame = [UIScreen mainScreen].bounds;
    [window addSubview:self];
    [window addSubview:self.mainView];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.mainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        if (self.isShowBg) {
            self.alpha = 1;
        }
    }];
}

- (void)showInView:(UIView *)view {
    self.mainView.alpha = 1;
    if (_showFrom == WarningCardShowFromTopCenter || _showFrom == WarningCardShowFromBottomCenter) {
        _mainView.transform = CGAffineTransformMakeScale(1.0, 0.00001);
    } else {
        _mainView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }
    self.frame = view.bounds;
    [view addSubview:self];
    [view addSubview:self.mainView];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.mainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        if (self.isShowBg) {
            self.alpha = 1;
        }
    }];
}

- (void)hide {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = 0;
        self.mainView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.mainView removeFromSuperview];
    }];
}

#pragma mark - action
- (void)handleTapBackground {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(ejwarningCardViewHide)]) {
        [self.delegate ejwarningCardViewHide];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EJWarningCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EJIgnoreCardCell"];
    if (!cell) {
        cell = [[EJWarningCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EJIgnoreCardCell"];
        cell.selectionStyle = _selectionStyle;
        cell.backgroundColor = [UIColor clearColor];
        [cell setType:_type Img:_selectedImg cellSize:CGSizeMake(CGRectGetWidth(tableView.frame), _cellHeight) contentLeft:_contentLeft contentRight:_contentRight selectedImageSpace:_selectedImageSpace];
    }
    
    if (_separatorStyle == UITableViewCellSeparatorStyleNone) {
        cell.bottomLine.hidden = YES;
    } else {
        if (indexPath.row == ([self.titleArray count] - 1)) {
            cell.bottomLine.hidden = YES;
        } else {
            cell.bottomLine.hidden = NO;
            cell.bottomLine.frame = CGRectMake(_separatorInset.left, _cellHeight - 0.75, _size.width - _separatorInset.left - _separatorInset.right, 0.5);
            if (_separatorColor) {
                cell.bottomLine.backgroundColor = _separatorColor;
            }
        }
    }
    
    
    cell.img.hidden = YES;
    if (_selectedImg) {
        if (_selectedIndex == indexPath.row) {
            cell.img.hidden = NO;
        }
    }
    
    cell.titleLab.font = _titleFont;
    cell.titleLab.textColor = _textColor;
    cell.titleLab.textAlignment = _textAlignment;
    cell.titleLab.text = [self.titleArray objectAtIndex:indexPath.row];
    if ([self.imageArray count] > 0) {
        [cell.imageView setImage:[UIImage imageNamed:[self.imageArray objectAtIndex:indexPath.row]]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedImg) {
        _selectedIndex = indexPath.row;
        [_tableView reloadData];
    }
    if (_autoHidden) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.alpha = 0;
            self.mainView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.mainView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(ejwarningCardView:ClickButtonAtIndex:)]) {
                [self.delegate ejwarningCardView:self ClickButtonAtIndex:indexPath.row];
            }
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(ejwarningCardView:ClickButtonAtIndex:)]) {
            [self.delegate ejwarningCardView:self ClickButtonAtIndex:indexPath.row];
        }
    }
}

#pragma mark - getter and setter
- (UIImageView *)mainView {
    if (!_mainView) {
        _mainView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _size.width, _size.height)];
        _mainView.userInteractionEnabled = YES;
//        _mainView.contentMode = UIViewContentModeScaleToFill;
        [_mainView addSubview:self.tableView];
    }
    return _mainView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _size.width, _size.height) style:UITableViewStylePlain];
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

@end
