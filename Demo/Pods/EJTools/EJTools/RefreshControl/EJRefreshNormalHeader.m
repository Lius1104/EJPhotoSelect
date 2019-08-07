//
//  EJRefreshNormalHeader.m
//  IOSParents
//
//  Created by Lius on 2017/4/1.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "EJRefreshNormalHeader.h"

@implementation EJRefreshNormalHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (EJRefreshNormalHeader *)ej_refreshNormalHeaderWithTarget:(id)target refreshingAction:(SEL)action {
    EJRefreshNormalHeader *header = [EJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:action];
    header.stateLabel.textColor = [UIColor lightGrayColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
    return header;
}

@end
