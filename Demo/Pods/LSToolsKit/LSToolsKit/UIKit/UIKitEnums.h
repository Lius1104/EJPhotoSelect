//
//  UIKitEnums.h
//  LSToolsKitDemo
//
//  Created by 刘爽 on 2018/11/14.
//  Copyright © 2018 刘爽. All rights reserved.
//

#ifndef UIKitEnums_h
#define UIKitEnums_h

/**
 扩展点击范围的方向, 可多选
 */
typedef NS_OPTIONS(NSUInteger, ExpandingDirectionType) {
    /// 不扩大响应范围
    ExpandingDirectionNone                  = 1 << 0,
    /// 向上扩大响应区域
    ExpandingDirectionTop                   = 1 << 1,
    /// 向下扩大响应区域
    ExpandingDirectionBottom                = 1 << 2,
    /// 向左扩大响应区域
    ExpandingDirectionLeft                  = 1 << 3,
    /// 向右扩大响应区域
    ExpandingDirectionRight                 = 1 << 4,
    /// 全方向扩大响应区域
    ExpandingDirectionAll                   = 0x0000001E
};

#endif /* UIKitEnums_h */
