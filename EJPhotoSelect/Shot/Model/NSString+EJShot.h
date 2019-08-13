//
//  NSString+EJShot.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (EJShot)

+ (NSString *)ej_shotDicPath;

+ (NSString *)shortedSecond:(CGFloat)second;

@end

NS_ASSUME_NONNULL_END
