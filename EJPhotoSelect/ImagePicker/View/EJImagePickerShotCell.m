//
//  EJImagePickerShotCell.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImagePickerShotCell.h"

@implementation EJImagePickerShotCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)handleClickShotButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ej_imagePickerShotCellDidClick:)]) {
        [self.delegate ej_imagePickerShotCellDidClick:self];
    }
}

@end
