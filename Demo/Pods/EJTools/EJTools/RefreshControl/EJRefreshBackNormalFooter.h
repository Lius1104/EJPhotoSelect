//
//  EJRefreshBackNormalFooter.h
//  IOSParents
//
//  Created by Lius on 2017/4/1.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@interface EJRefreshBackNormalFooter : MJRefreshBackNormalFooter

+ (instancetype)ej_footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end
