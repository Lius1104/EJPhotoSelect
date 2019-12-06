//
//  EJShotItemsView.m
//  EJPhotoBrowser
//
//  Created by ejiang on 2019/12/6.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJShotItemsView.h"

@implementation EJShotItemsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 45, 20)];
        _selectScroll.clipsToBounds = NO;
        _selectScroll.pagingEnabled = YES;
        _selectScroll.showsHorizontalScrollIndicator = NO;
        _selectScroll.showsVerticalScrollIndicator = NO;
        
        UIButton * photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton setTitle:@"照片" forState:UIControlStateNormal];
        [photoButton setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
#if defined(kMajorColor)
        [photoButton setTitleColor:kMajorColor forState:UIControlStateSelected];
#else
        [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
#endif
        
        photoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        photoButton.frame = CGRectMake(0, 0, 45, 20);
        photoButton.selected = YES;
        photoButton.tag = 0;
        
        [_selectScroll addSubview:photoButton];
        
        UIButton * videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton setTitle:@"视频" forState:UIControlStateNormal];
        [videoButton setTitleColor:UIColorHex(ffffff) forState:UIControlStateNormal];
#if defined(kMajorColor)
        [videoButton setTitleColor:kMajorColor forState:UIControlStateSelected];
#else
        [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
#endif
        videoButton.titleLabel.font = [UIFont systemFontOfSize:13];
        videoButton.frame = CGRectMake(45, 0, 45, 20);
        videoButton.tag = 1;
        [_selectScroll addSubview:videoButton];
        _selectScroll.contentSize = CGSizeMake(90, 0);
        
        _selectItem = @[photoButton, videoButton];
        
        [self addSubview:_selectScroll];
        
        _selectedDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
#if defined(kMajorColor)
        _selectedDot.backgroundColor = kMajorColor;
#else
        _selectedDot.backgroundColor = [UIColor whiteColor];
#endif
        _selectedDot.layer.cornerRadius = 2;
        _selectedDot.layer.masksToBounds = YES;
        [self addSubview:_selectedDot];
        
        [_selectScroll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(45);
            make.top.equalTo(self);
        }];
        [_selectedDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(4, 4));
            make.top.equalTo(_selectScroll.mas_bottom);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGRect firstRect = [_selectItem.firstObject convertRect:_selectItem.firstObject.bounds toView:self];
        CGRect lastRect = [_selectItem.lastObject convertRect:_selectItem.lastObject.bounds toView:self];
        BOOL firstContains = CGRectContainsPoint(firstRect, point);
        BOOL lastContains = CGRectContainsPoint(lastRect, point);
        NSLog(@"hhhh");
        if (firstContains) {
            return _selectItem.firstObject;
        } else if (lastContains) {
            return _selectItem.lastObject;
        }
        return self;
    }
    return nil;
}

@end
