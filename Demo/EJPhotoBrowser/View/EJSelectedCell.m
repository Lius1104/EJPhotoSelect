//
//  EJSelectedCell.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/5.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJSelectedCell.h"

@implementation EJSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configClickDeleteBlock:(clickDeleteBlock)block {
    self.block = [block copy];
}

- (IBAction)handleClickDeleteButton:(UIButton *)sender {
    if (_block) {
        self.block();
    }
}

@end
