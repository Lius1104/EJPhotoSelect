//
//  LSTableDataSource.h
//  IOSParents
//
//  Created by ejiang on 2017/1/17.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 table view cell configure block

 @param cell 需要配置的cell
 @param item 需要配置的cell对应的数据
 */
typedef void(^TableViewCellConfigureBlock)(id cell, id item);

///cell 的创建类型
typedef enum : NSUInteger {
    CellTypeForCode,//纯代码创建cell
    CellTypeForNib,//xib创建cell
    CellTypeForStoryboard,//storyboard创建cell
} CellType;

///添加行的位置
typedef enum : NSUInteger {
    InsertIntoBelow,//添加到现有行的下面
    InsertIntoAbove,//添加到现有行的上面
    NotInsert,//不插入行
} TypeOfInsert;

/**
 将 table view dataSource 代理抽出，减轻视图控制器的代码量
 */
@interface LSTableDataSource : NSObject<UITableViewDataSource>

/**
 是否所有行可以编辑，默认是NO;
 @brief 需要所有行都编辑的情况下：可以将 setCanEditRows 中的数组置为nil，或者当编辑状态不是’插入‘时，可以不调用 setCanEditRows 方法; 当tableview 调用 setEdit:animated: 方法时如果需要所有行都可以编辑，需要将isAllCanEdit置为YES;
 */
@property (nonatomic, assign) BOOL isAllCanEdit;

/**
 是否所有行可以移动, 默认是NO;
 */
@property (nonatomic, assign) BOOL isAllCanMove;

/**
 初始化方法, 同时需要配合设置cell的创建类型方法使用

 @param items 数据源
 @param aCellIdentifier cell标志符
 @param aConfigureCellBlock 配置cell的block  
 @see TableViewCellConfigureBlock
 @see setCellType:classNameOfCell:
 @return TableDataSource
 */
- (instancetype)initWithItems:(NSMutableArray *)items cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;

/**
 设置cell类型和cell的类名

 @param type cell创建类型，包括纯代码，nib，storyboard
 @param className 当cell的类型是纯代码创建时需要传cell类的类名，其他类型可传nil
 @exception NSException 当cell的类型是纯代码类型时类名不能为空, 需要使用类名创建cell
 */
- (void)setCellType:(CellType)type classNameOfCell:(NSString *)className;

/**
 设置分组, 每个分组中的行数

 @brief 可选方法, 不调用该方法时默认只有一个分组, 当有多个分组存在的时候，如果数据源的数据个数有变化时，需要重新设置分组情况，否则默认将多出的数据源放在最后一个分组中
 @see updateDataSource:
 @see incrementalUpdateDataSource:
 @param numberOfRows 分组情况的数组，每个元素表示每个分组中的行的个数，数组元素个数表示分组个数
 @exception NSException 当传进来的数组中的每个分组的行的总数大于数据源的总数时，将会产生数组越界，所以需要在这里就进行控制
 */
- (void)setNumberOfRows:(NSArray *)numberOfRows;

/**
 设置可以编辑的行

 @brief 可选方法，编辑状态为插入时，需要调用该方法；而当需要列表里的所有的行都进入编辑状态，'canEditRows' 可为 nil. 
        当需要所有行都是可编辑状态同时编辑状态不是‘插入’时，可以不调用该方法。
 @param canEditRows 可以编辑的行的数组，数组中的元素可以是NSIndexPath或者NSIndexSet
 @param insertType 编辑状态下的cell, 如果是插入行的状态，需要设置插入行的位置
 */
- (void)setCanEditRows:(NSArray *)canEditRows typeOfInsert:(TypeOfInsert)insertType;

/**
 设置可以移动的行

 @param canMoveRows 可以移动的行的数组，数组中的元素可以是NSIndexPath或者NSIndexSet
 @param isInGroup 是否在组内进行移动
 */
- (void)setCanMoveRows:(NSArray *)canMoveRows whetherMoveInGroup:(BOOL)isInGroup;

/**
 更新整个数据源

 @param source 需要传完整的数据源
 @warning 如果有多个分组需要重新设置分组, 否则默认添加到最后一个分组
 @see setNumberOfRows:
 */
- (void)updateDataSource:(NSMutableArray *)source;

/**
 增量更新数据源

 @param incrementalSource 只需传增量的数据，如果有多个分组需要重新设置分组, 否则显示不全
 @warning 如果有多个分组需要重新设置分组, 否则默认添加到最后一个分组
 @see setNumberOfRows:
 */
- (void)incrementalUpdateDataSource:(NSArray *)incrementalSource;

/**
 获取某个cell上的model

 @brief 已经做过越界处理
 @param indexPath 需要获取model的位置
 @return model
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
