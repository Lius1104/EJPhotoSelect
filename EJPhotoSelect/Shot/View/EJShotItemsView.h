//
//  EJShotItemsView.h
//  EJPhotoBrowser
//
//  Created by ejiang on 2019/12/6.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EJShotItemsView : UIView

@property (nonatomic, strong) UIView * selectedDot;
@property (nonatomic, strong) UIScrollView * selectScroll;
@property (nonatomic, strong) NSArray<UIButton *> * selectItem;

@end

NS_ASSUME_NONNULL_END
