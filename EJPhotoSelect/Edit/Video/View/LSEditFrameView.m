//
//  LSEditFrameView.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/17.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSEditFrameView.h"

@interface LSEditFrameView () {
    CGSize _itemSize;
}

@property (nonatomic, strong) CALayer * validLayer;

@property (nonatomic, strong) UIImageView * leftView;

@property (nonatomic, strong) UIImageView * rightView;

@end

@implementation LSEditFrameView

- (instancetype)initWithItemSize:(CGSize)itemSize initRect:(CGRect)initRect {
    self = [super init];
    if (self) {
        _itemSize = itemSize;
        _initRect = initRect;
        [self setupUI];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //扩大下有效范围
    CGRect left = _leftView.frame;
    left.origin.x -= _itemSize.width/2;
    left.size.width += _itemSize.width/2;
    CGRect right = _rightView.frame;
    right.size.width += _itemSize.width/2;
    
    if (CGRectContainsPoint(left, point)) {
        return _leftView;
    }
    if (CGRectContainsPoint(right, point)) {
        return _rightView;
    }
    return nil;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _validLayer = [[CALayer alloc] init];
    _validLayer.frame = _initRect;
    _validLayer.borderWidth = 2;
    _validLayer.borderColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:_validLayer];
    
    _leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left"]];
    _leftView.userInteractionEnabled = YES;
    _leftView.tag = 0;
    UIPanGestureRecognizer *lg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [_leftView addGestureRecognizer:lg];
    [self addSubview:_leftView];
    
    _rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    _rightView.userInteractionEnabled = YES;
    _rightView.tag = 1;
    UIPanGestureRecognizer *rg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [_rightView addGestureRecognizer:rg];
    [self addSubview:_rightView];
}

- (void)setValidRect:(CGRect)validRect {
    _validRect = validRect;
    
    _leftView.frame = CGRectMake(validRect.origin.x, 0, _itemSize.width/2, _itemSize.height);
    _rightView.frame = CGRectMake(validRect.origin.x+validRect.size.width-_itemSize.width/2, 0, _itemSize.width/2, _itemSize.height);
    
    [self setNeedsDisplay];
}

- (void)setInitRect:(CGRect)initRect {
    _initRect = initRect;
    _validLayer.frame = _initRect;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.validRect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint topPoints[2];
    topPoints[0] = CGPointMake(self.validRect.origin.x, 0);
    topPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, 0);
    
    CGPoint bottomPoints[2];
    bottomPoints[0] = CGPointMake(self.validRect.origin.x, _itemSize.height);
    bottomPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, _itemSize.height);
    
    CGContextAddLines(context, topPoints, 2);
    CGContextAddLines(context, bottomPoints, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - action
- (void)handlePanAction:(UIGestureRecognizer *)pan {
    _validLayer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4].CGColor;
    CGPoint point = [pan locationInView:self];
    
    CGRect rct = self.validRect;
    
    const CGFloat W = CGRectGetMaxX(_initRect);
    CGFloat minX = CGRectGetMinX(_initRect);
    CGFloat maxX = W;
    
    switch (pan.view.tag) {
        case 0: {
            //left
            maxX = rct.origin.x + rct.size.width - _itemSize.width;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width -= (point.x - rct.origin.x);
            rct.origin.x = point.x;
        }
            break;
            
        case 1:
        {
            //right
            minX = rct.origin.x + _itemSize.width/2;
            maxX = W - _itemSize.width/2;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width = (point.x - rct.origin.x + _itemSize.width/2);
        }
            break;
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (self.delegate && [self.delegate respondsToSelector:@selector(ls_editFrameValidRectChanged)]) {
                [self.delegate ls_editFrameValidRectChanged];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            _validLayer.borderColor = [UIColor clearColor].CGColor;
            if (self.delegate && [self.delegate respondsToSelector:@selector(ls_editFrameValidRectEndChange)]) {
                [self.delegate ls_editFrameValidRectEndChange];
            }
            break;
            
        default:
            break;
    }
    
    
    self.validRect = rct;
}

@end
