//
//  EJConfigVC.m
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/5.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJConfigVC.h"
#import "EJConfigModel.h"

@interface EJConfigVC ()<UITextFieldDelegate, UIScrollViewDelegate> {
    EJConfigModel * _config;
}

@property (weak, nonatomic) IBOutlet UITextField *maxSelectCountTF;
@property (weak, nonatomic) IBOutlet UITextField *cropScaleTF;
@property (weak, nonatomic) IBOutlet UITextField *videoCropDurationTF;

@property (weak, nonatomic) IBOutlet UITextField *topTF;
@property (weak, nonatomic) IBOutlet UITextField *leftTF;
@property (weak, nonatomic) IBOutlet UITextField *bottomTF;
@property (weak, nonatomic) IBOutlet UITextField *rightTF;
@property (weak, nonatomic) IBOutlet UITextField *cellSpaceTF;
@property (weak, nonatomic) IBOutlet UITextField *numOfCellsTF;

@end

@implementation EJConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _config = [[EJConfigModel alloc] init];
}

#pragma mark - action
- (IBAction)handleClickCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleClickDone:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Config" object:nil userInfo:@{@"Config" : _config}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleShotSwitchChanged:(UISwitch *)sender {
    NSLog(@"%@", sender.isOn ? @"允许拍摄": @"不允许拍摄");
    _config.allowShot = sender.isOn;
}

- (IBAction)handleOrderSwitchChanged:(UISwitch *)sender {
    NSLog(@"%@", sender.isOn ? @"正序排列": @"倒序排列");
    _config.increaseOrder = sender.isOn;
}
- (IBAction)handleCropSwitchChanged:(UISwitch *)sender {
    _config.allowCrop = sender.isOn;
}

- (IBAction)handleTypeSegmentChanged:(UISegmentedControl *)sender {
    _config.sourceType = sender.selectedSegmentIndex;
    switch (sender.selectedSegmentIndex) {
        case 0:
            NSLog(@"只能选择图片");
            break;
        case 1:
            NSLog(@"只能选择视频");
            break;
        default:
            NSLog(@"可全选");
            break;
    }
}

- (IBAction)handleClickSingleSelect:(UISwitch *)sender {
    _config.singleSelect = sender.isOn;
}


- (IBAction)handleEditSwitchChanged:(UISwitch *)sender {
    _config.directEdit = sender.isOn;
}

- (IBAction)handlePreviewDelSwitchChanged:(UISwitch *)sender {
    _config.previewDelete = sender.isOn;
}

- (IBAction)handleForcedCropSwitchChanged:(UISwitch *)sender {
    _config.forcedCrop = sender.isOn;
}

- (IBAction)handleBrowserAfterShotChanged:(UISwitch *)sender {
    _config.browserAfterShot = sender.isOn;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _maxSelectCountTF) {
        NSLog(@"selected text field changed : %@", textField.text);
        NSUInteger num = 0;
        if ([textField.text length] > 0) {
            num = [textField.text unsignedIntegerValue];
        }
        _config.maxSelectCount = num;
        return;
    }
    if (textField == _cropScaleTF) {
        CGFloat scale = 0;
        if ([textField.text length] > 0) {
            scale = [textField.text floatValue];
        }
        _config.cropScale = scale;
        return;
    }
    if (textField == _videoCropDurationTF) {
        NSUInteger duration = 180;
        if ([textField.text length] > 0) {
            duration = [textField.text unsignedIntegerValue];
        }
        _config.videoDefaultDuration = duration;
        return;
    }
    
    if (textField == _topTF) {
        CGFloat top = 0;
        if ([textField.text length] > 0) {
            top = [textField.text floatValue];
        }
        UIEdgeInsets insert = UIEdgeInsetsMake(
                                               top,
                                               _config.sectionInsets.left,
                                               _config.sectionInsets.bottom,
                                               _config.sectionInsets.right
                                               );
        _config.sectionInsets = insert;
        return;
    }
    if (textField == _leftTF) {
        CGFloat left = 0;
        if ([textField.text length] > 0) {
            left = [textField.text floatValue];
        }
        UIEdgeInsets insert = UIEdgeInsetsMake(
                                               _config.sectionInsets.top,
                                               left,
                                               _config.sectionInsets.bottom,
                                               _config.sectionInsets.right
                                               );
        _config.sectionInsets = insert;
        return;
    }
    if (textField == _bottomTF) {
        CGFloat bottom = 0;
        if ([textField.text length] > 0) {
            bottom = [textField.text floatValue];
        }
        UIEdgeInsets insert = UIEdgeInsetsMake(
                                               _config.sectionInsets.top,
                                               _config.sectionInsets.left,
                                               bottom,
                                               _config.sectionInsets.right
                                               );
        _config.sectionInsets = insert;
        return;
    }
    if (textField == _rightTF) {
        CGFloat right = 0;
        if ([textField.text length] > 0) {
            right = [textField.text floatValue];
        }
        UIEdgeInsets insert = UIEdgeInsetsMake(
                                               _config.sectionInsets.top,
                                               _config.sectionInsets.left,
                                               _config.sectionInsets.bottom,
                                               right
                                               );
        _config.sectionInsets = insert;
        return;
    }
    if (textField == _numOfCellsTF) {
        NSUInteger num = 4;
        if ([textField.text length] > 0) {
            num = [textField.text unsignedIntegerValue];
        }
        _config.numOfLineCells = num;
        return;
    }
    if (textField == _cellSpaceTF) {
        NSUInteger num = 2;
        if ([textField.text length] > 0) {
            num = [textField.text unsignedIntegerValue];
        }
        _config.cellSpace = num;
        return;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _cropScaleTF || textField == _topTF || textField == _leftTF || textField == _bottomTF || textField == _rightTF || textField == _cellSpaceTF) {
        NSString* number = @"^[0-9]+$";
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", number];
        if ([string isEqualToString:@""] || [string isEqualToString:@"."] || [predicate evaluateWithObject:string]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

@end
