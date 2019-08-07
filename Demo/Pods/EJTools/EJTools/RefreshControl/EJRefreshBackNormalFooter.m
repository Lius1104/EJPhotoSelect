//
//  EJRefreshBackNormalFooter.m
//  IOSParents
//
//  Created by Lius on 2017/4/1.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "EJRefreshBackNormalFooter.h"

@implementation EJRefreshBackNormalFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)ej_footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    EJRefreshBackNormalFooter *footer = [EJRefreshBackNormalFooter footerWithRefreshingTarget:target refreshingAction:action];
    footer.stateLabel.textColor = [UIColor lightGrayColor];
//    footer.triggerAutomaticallyRefreshPercent = -2;
    return footer;
}

@end
