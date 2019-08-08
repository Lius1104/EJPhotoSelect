//
//  NSDate+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (EJAdd)

+ (NSInteger)ej_compareDete:(NSDate*)beforeDate Date:(NSDate *)NextDate;

- (BOOL)ej_isSameDayWithDate:(NSDate *)date;

- (BOOL)ej_isSameYearWithDate:(NSDate *)date;

- (BOOL)ej_isEqualToDateIgnoringTime:(NSDate *)aDate;

- (BOOL)ej_isEarlierThanDate:(NSDate *)aDate;

- (BOOL)ej_isLaterThanDate:(NSDate *)aDate;

- (NSString *)ej_formattedTime;

- (NSString *)ej_formatIMMessageDate;

+ (NSDate *)ej_dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;

- (BOOL)ej_isThisYear;

// 获取date当前月的第一天是星期几
+ (NSInteger)ej_weekdayOfFirstDayInDate:(NSDate *)date;

//获取当前月天数
+ (NSInteger)ej_totalDaysInMonthOfDate:(NSDate *)date;

- (NSString *)ej_getMonthStart;

- (NSString *)ej_getMonthEnd;

- (NSString *)ej_getWeekday;

+ (NSInteger)ej_secondFromStartTime:(NSDate *)startTime endTime:(NSDate *)endTime;

- (NSString *)ej_stringForTimeline;

+ (NSString *)ej_localDate;

@end

NS_ASSUME_NONNULL_END
