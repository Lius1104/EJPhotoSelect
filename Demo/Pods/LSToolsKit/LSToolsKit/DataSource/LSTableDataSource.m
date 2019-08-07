//
//  LSTableDataSource.m
//  IOSParents
//
//  Created by ejiang on 2017/1/17.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "LSTableDataSource.h"
#import "NSMutableArray+LSAdd.h"


@implementation LSTableDataSource {
    NSString *_cellId;//cell 标识符
    NSMutableArray *_numberOfRows;//每个分组中 row 的个数的数组
    TableViewCellConfigureBlock _configureBlock;//配置 cell 的 block 块
    NSMutableArray *_itemsArray;//数据源数组
    CellType _type;//cell 的创建类型
    TypeOfInsert _insertType;//添加行的位置
    NSString *_classNameOfCell;//纯代码创建的 cell 需要传入自定义 cell 的类名
    NSMutableArray *_canEditRows, *_canMoveRows;//能够编辑的行，能够移动的行
    BOOL _isMoveInGroup;//可以移动时的限制，组内移动，跨组移动
}

#pragma mark -- 创建方法（创建对象必须要调用的方法）
- (instancetype)init {
    return nil;
}

- (instancetype)initWithItems:(NSMutableArray *)items cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        if (items == nil) {
            _itemsArray = [NSMutableArray arrayWithCapacity:1];
        } else {
            _itemsArray = [items mutableCopy];
        }
        if ([aCellIdentifier length] == 0) {
            _cellId = @"Cell";
        } else {
            _cellId = aCellIdentifier;
        }
        _configureBlock = [aConfigureCellBlock copy];
        _numberOfRows = [@[@([_itemsArray count])] mutableCopy];
        _isAllCanEdit = NO;
        _isAllCanMove = NO;
    }
    return self;
}

- (void)setCellType:(CellType)type classNameOfCell:(NSString *)className {
    _type = type;
    _classNameOfCell = className;
    if (_type == CellTypeForCode && [_classNameOfCell length] == 0) {
        NSException *exception = [NSException exceptionWithName:@"类名不能为空" reason:@"代码创建的table view cell 的类名不能为空，需要使用类名创建cell" userInfo:nil];
        @throw exception;
    }
}

#pragma mark -- 功能方法（设置table view 的分组，Edit， Move等）
- (void)setNumberOfRows:(NSArray *)numberOfRows {
    if (numberOfRows == nil) {
        _numberOfRows = [@[@([_itemsArray count])] mutableCopy];
    } else {
        int index = 0;
        for (NSNumber *number in numberOfRows) {
            NSLog(@"%@", number);
            index = index + [number intValue];
        }
        if (index > [_itemsArray count]) {
            NSException *exception = [[NSException alloc] initWithName:@"数组越界" reason:@"创建table view dataSource 时 numberOfRows的总数大于数据源的元素个数" userInfo:nil];
            @throw exception;
        }
        _numberOfRows = [numberOfRows mutableCopy];
    }
}

- (void)setCanEditRows:(NSArray *)canEditRows typeOfInsert:(TypeOfInsert)insertType {
    if (canEditRows == nil) {
        _isAllCanEdit = YES;
    } else {
        _isAllCanEdit = NO;
    }
    _canEditRows = [canEditRows mutableCopy];
    _insertType = insertType;
}

- (void)setCanMoveRows:(NSArray *)canMoveRows whetherMoveInGroup:(BOOL)isGroup {
    _canMoveRows = [canMoveRows mutableCopy];
    _isMoveInGroup = isGroup;
}

#pragma mark -- 更新数据源的方法

- (void)updateDataSource:(NSMutableArray *)source {
    NSInteger oldCount = [_itemsArray count];
    NSInteger newCount = [source count];
    _itemsArray = [source mutableCopy];
    if ([_numberOfRows count] == 1) {
        NSNumber *num = [_numberOfRows firstObject];
        num = @([_itemsArray count]);
        [_numberOfRows replaceObjectAtIndex:0 withObject:num];
    } else {
        NSNumber *num = [_numberOfRows lastObject];
        num = @([num integerValue] + (newCount - oldCount));
        [_numberOfRows replaceObjectAtIndex:([_numberOfRows count] - 1) withObject:num];
    }
}

- (void)incrementalUpdateDataSource:(NSArray *)incrementalSource {
    [_itemsArray addObjectsFromArray:incrementalSource];
    if ([_numberOfRows count] == 1) {
        NSNumber *num = [_numberOfRows firstObject];
        num = @([_itemsArray count]);
        [_numberOfRows replaceObjectAtIndex:0 withObject:num];
    } else {
        NSNumber *num = [_numberOfRows lastObject];
        num = @([num integerValue] + [incrementalSource count]);
        [_numberOfRows replaceObjectAtIndex:([_numberOfRows count] - 1) withObject:num];
    }
}

#pragma mark -- 获取cell上的model

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [self indexWithIndexPath:indexPath];
    return [_itemsArray objectAtIndex:index];
}

#pragma mark - private method
//根据indexPath获取对应的数组中的index
- (NSUInteger)indexWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = 0;
    for (int i = 0; i < indexPath.section; i++) {
        NSNumber *number = [_numberOfRows objectAtIndex:i];
        index += [number unsignedIntegerValue];
    }
    index += indexPath.row;
    if (index > [_itemsArray count]) {
        NSException *exception = [[NSException alloc] initWithName:@"获取数据源失败" reason:@"indexPath 数组越界" userInfo:nil];
        @throw exception;
    }
    return index;
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_numberOfRows count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (_numberOfSection == 1) {
//        return [_itemsArray count];
//    } else {
        return [[_numberOfRows objectAtIndex:section] integerValue];
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (_type) {
        case CellTypeForCode:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:_cellId];
            if (!cell) {
                if ([_classNameOfCell length] != 0) {
                    Class cellClass = NSClassFromString(_classNameOfCell);
                    cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellId];
                } else {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellId];
                }
            }
        }
            break;
        case CellTypeForNib:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:_cellId forIndexPath:indexPath];
        }
            break;
        case CellTypeForStoryboard:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:_cellId forIndexPath:indexPath];
        }
            break;
    }

    id item = [self itemAtIndexPath:indexPath];
    if (_configureBlock != nil) _configureBlock(cell, item);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isAllCanEdit == YES) {
        return YES;
    }
    for (id index in _canEditRows) {
        if ([index isKindOfClass:[NSIndexSet class]]) {
            NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:indexPath.section];
            if ([set isEqualToIndexSet:index]) {
                return YES;
            }
        }
        if ([index isKindOfClass:[NSIndexPath class]]) {
            if (((NSIndexPath *)index).section == indexPath.section && ((NSIndexPath *)index).row == indexPath.row) {
                return YES;
            }
        }
    }
    for (id index in _canMoveRows) {
        if ([index isKindOfClass:[NSIndexSet class]]) {
            NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:indexPath.section];
            if ([set isEqualToIndexSet:index]) {
                return YES;
            }
        }
        if ([index isKindOfClass:[NSIndexPath class]]) {
            if (((NSIndexPath *)index).section == indexPath.section && ((NSIndexPath *)index).row == indexPath.row) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleNone:
        {

        }
            break;
        case UITableViewCellEditingStyleDelete:
        {
            NSLog(@"删除");
            NSLog(@"indexPath : {%ld, %ld}", (long)indexPath.section, (long)indexPath.row);

            id item = [self itemAtIndexPath:indexPath];
            [_itemsArray removeObject:item];
            if ([[_numberOfRows objectAtIndex:indexPath.section] integerValue] == 1) {
                [_numberOfRows removeObjectAtIndex:indexPath.section];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
                [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            } else {
                NSNumber *number = [_numberOfRows objectAtIndex:indexPath.section];
                number = @([number integerValue] - 1);
                [_numberOfRows replaceObjectAtIndex:indexPath.section withObject:number];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
            break;
        case UITableViewCellEditingStyleInsert:
        {
            //添加到上面／下面
            [_numberOfRows removeAllObjects];
            for (NSInteger index = 0; index < [tableView numberOfSections]; index++) {
                if (indexPath.section == index) {
                    [_numberOfRows addObject:@(([tableView numberOfRowsInSection:index] + 1))];
                } else {
                    [_numberOfRows addObject:@([tableView numberOfRowsInSection:index])];
                }
            }
            id item = [self itemAtIndexPath:indexPath];
            NSUInteger index = [self indexWithIndexPath:indexPath];
            switch (_insertType) {
                case InsertIntoBelow://添加新的cell 到当前cell 的下面
                {
                    if (index == [_itemsArray count] - 1) {
                        [_itemsArray addObject:item];
                    } else {
                        [_itemsArray insertObject:item atIndex:[self indexWithIndexPath:indexPath] + 1];
                    }
                    NSLog(@"{%ld, %ld}", (long)indexPath.section, (long)indexPath.row);
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                    [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                }
                    break;
                case InsertIntoAbove://添加新的cell 到当前cell 的上面
                {
                    NSLog(@"{%ld, %ld}", (long)indexPath.section, (long)indexPath.row);
                    [_itemsArray insertObject:item atIndex:[self indexWithIndexPath:indexPath]];
                    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                }
                    break;
                case NotInsert:
                    break;
            }
        }
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    for (id index in _canMoveRows) {
        if ([index isKindOfClass:[NSIndexSet class]]) {
            NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:indexPath.section];
            if ([set isEqualToIndexSet:index]) {
                return YES;
            }
        }
        if ([index isKindOfClass:[NSIndexPath class]]) {
            if (((NSIndexPath *)index).section == indexPath.section && ((NSIndexPath *)index).row == indexPath.row) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (_isMoveInGroup) {//在组内移动
        if (sourceIndexPath.section != destinationIndexPath.section) {
            NSLog(@"移动无效");
            //移动回原位, 使用GCD延迟的原因是因为无效移动还没有结束
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tableView moveRowAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
            });
            return;
        } else {
            NSLog(@"移动有效");
            //交换数据源中的数据位置
            NSUInteger sourceIndex = [self indexWithIndexPath:sourceIndexPath];
            NSUInteger desIndex = [self indexWithIndexPath:destinationIndexPath];
            [_numberOfRows removeAllObjects];
            for (NSInteger index = 0; index < [tableView numberOfSections]; index++) {
                [_numberOfRows addObject:@([tableView numberOfRowsInSection:index])];
            }
            [_itemsArray moveObjectFromIndex:sourceIndex toIndex:desIndex];
        }
    } else {//可以跨组移动
        //判断destinationIndexPath是否是可移动的项
        BOOL isCanMove = NO;
        for (id index in _canMoveRows) {
            if ([index isKindOfClass:[NSIndexSet class]]) {
                NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:destinationIndexPath.section];
                if ([set isEqualToIndexSet:index]) {
                    isCanMove = YES;
                    break;
                }
            }
            if ([index isKindOfClass:[NSIndexPath class]]) {
                if (((NSIndexPath *)index).section == destinationIndexPath.section) {
                    isCanMove = YES;
                    break;
                }
            }
        }
        if (isCanMove) {//移动有效
            NSLog(@"移动有效");
            //交换数据源数据
            NSUInteger sourceIndex = [self indexWithIndexPath:sourceIndexPath];
            NSUInteger desIndex = [self indexWithIndexPath:destinationIndexPath];
            [_numberOfRows removeAllObjects];
            for (NSInteger index = 0; index < [tableView numberOfSections]; index++) {
                [_numberOfRows addObject:@([tableView numberOfRowsInSection:index])];
            }
            [_itemsArray moveObjectFromIndex:sourceIndex toIndex:desIndex];
        } else {
            NSLog(@"移动无效");
            //移动回原位, 使用GCD延迟的原因是因为无效移动还没有结束
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [tableView moveRowAtIndexPath:destinationIndexPath toIndexPath:sourceIndexPath];
            });
        }
    }
}

@end
