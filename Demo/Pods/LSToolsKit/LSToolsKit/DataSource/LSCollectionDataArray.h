//
//  LSCollectionDataArray.h
//  IOSParents
//
//  Created by ejiang on 2017/1/17.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 collection cell 配置

 @param cell 需要配置model的cell，具体使用时需将id类型改为具体的cell类型
 @param model cell所对应的model，具体使用时需要将id类型改为具体的model类型
 */
typedef void(^CollectionItemConfigureBlock)(id cell, id model);

/**
 将 Collection View DataSource 代理抽出，减轻视图控制器的代码量
 */
@interface LSCollectionDataArray : NSObject<UICollectionViewDataSource>

#pragma mark - 初始化对象
/**
 初始化方法

 @param sourcesArray 数据源
 @param aCellIdentifier cell 标志符
 @param block 配置 cell 的 block
 @return 返回 CollectionDataArray 对象
 */
- (instancetype)initWithsources:(NSMutableArray *)sourcesArray cellIdentifier:(NSString *)aCellIdentifier ConfigureItemBlock:(CollectionItemConfigureBlock)block;

#pragma mark - 获取某一 cell 对应的数据
/**
 获取某一 cell 对应的数据

 @param indexPath cell 的位置
 @return cell 上的 model
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - 更新数据源
/**
 更新整个数据源

 @param sources 整个数据源
 */
- (void)updateSources:(NSMutableArray *)sources;


/**
 增量更新数据源

 @param incrementalSource 增量数据数组
 */
//- (void)incrementalUpdateDataSource:(NSArray *)incrementalSource;

@end
