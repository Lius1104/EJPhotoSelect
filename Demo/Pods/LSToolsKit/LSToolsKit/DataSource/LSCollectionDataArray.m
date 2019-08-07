//
//  LSCollectionDataArray.m
//  IOSParents
//
//  Created by ejiang on 2017/1/17.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "LSCollectionDataArray.h"

@interface LSCollectionDataArray ()
//
//@property (nonatomic, copy) NSString *cellId;
//
//@property (nonatomic, assign) NSInteger numberOfSection;
//
//@property (nonatomic, copy) CollectionItemConfigureBlock block;
//
//@property (nonatomic, strong) NSMutableArray *sourcesArray;

@end

@implementation LSCollectionDataArray {
    NSString *_cellId;
    NSInteger _numberOfSection;
    CollectionItemConfigureBlock _block;
    NSMutableArray *_sourcesArray;
}


- (instancetype)initWithsources:(NSMutableArray *)sourcesArray cellIdentifier:(NSString *)aCellIdentifier ConfigureItemBlock:(CollectionItemConfigureBlock)block {
    self = [super init];
    if (self) {
        if (sourcesArray == nil) {
            _sourcesArray = [NSMutableArray arrayWithCapacity:1];
        } else {
            _sourcesArray = sourcesArray;
        }
        if ([aCellIdentifier length] == 0) {
            _cellId = @"Cell";
        } else {
            _cellId = aCellIdentifier;
        }
        _block = [block copy];
//        if (numberOfSection < 0) {
//            _numberOfSection = 0;
//        } else {
//            _numberOfSection = numberOfSection;
//        }
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [_sourcesArray objectAtIndex:(NSUInteger)indexPath.row];
}

- (void)updateSources:(NSMutableArray *)sources {
    _sourcesArray = sources;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return _numberOfSection;
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourcesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellId forIndexPath:indexPath];
    id model = [self itemAtIndexPath:indexPath];
    if (_block != nil) {
        _block(cell, model);
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

#pragma mark - getter and setter
//- (NSMutableArray *)sourcesArray {
//    if (!_sourcesArray) {
//        _sourcesArray = [NSMutableArray arrayWithCapacity:1];
//    }
//    return _sourcesArray;
//}

@end
