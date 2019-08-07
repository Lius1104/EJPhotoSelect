//
//  NSIndexSet+LSAdd.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/3.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSIndexSet (LSAdd)

/**
 IndexSet转IndexPath

 @param indexSet row set
 @param section section number
 @return NSIndexPath collection
 */
+ (NSArray<NSIndexPath *> *)indexPathsFromIndexSet:(NSIndexSet *)indexSet AtSection:(NSUInteger)section;

@end
