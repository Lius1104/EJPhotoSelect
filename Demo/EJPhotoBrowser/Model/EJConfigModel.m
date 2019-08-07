//
//  EJConfigModel.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/5.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJConfigModel.h"

@implementation EJConfigModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _allowShot = YES;
        _increaseOrder = NO;
        _sourceType = 2;
        _allowCrop = YES;
        _cropScale = 0;
        _videoDefaultDuration = 180;
        _maxSelectCount = 0;
        _directEdit = YES;
        _previewDelete = YES;
        _forcedCrop = YES;
        
        _sectionInsets = UIEdgeInsetsZero;
        _cellSpace = 2;
        _numOfLineCells = 4;
    }
    return self;
}

@end
