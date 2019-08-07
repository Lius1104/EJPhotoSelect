//
//  NSDateFormatter+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface NSDateFormatter (EJAdd)

+ (instancetype)dateFormatter;

+ (instancetype)dateFormatterWithFormat:(NSString *)dateFormat;

+ (instancetype)defaultDateFormatter;/*yyyy-MM-dd HH:mm:ss*/

@end

//NS_ASSUME_NONNULL_END
