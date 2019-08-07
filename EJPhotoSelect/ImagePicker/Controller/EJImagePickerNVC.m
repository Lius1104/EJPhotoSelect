//
//  EJImagePickerNVC.m
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "EJImagePickerNVC.h"
#import "EJImagePickerVC.h"

@interface EJImagePickerNVC ()<EJImagePickerDelegate>

@end

@implementation EJImagePickerNVC

- (void)dealloc {
    NSLog(@"EJImagePickerNVC dealloc.");
}

- (instancetype)initWithSourceType:(E_SourceType)sourceType MaxCount:(NSUInteger)maxCount SelectedSource:(NSMutableArray <PHAsset *>*)selectedSource increaseOrder:(BOOL)increaseOrder showShot:(BOOL)showShot allowCrop:(BOOL)allowCrop {
    EJImagePickerVC * imagePicker = [[EJImagePickerVC alloc] initWithSourceType:sourceType MaxCount:maxCount SelectedSource:selectedSource increaseOrder:increaseOrder showShot:showShot allowCrop:allowCrop];
    imagePicker.delegate = self;
    self = [super initWithRootViewController:imagePicker];
    if (self) {
        self.maxCount = maxCount == 0 ? 9 : maxCount;
        self.sourceType = sourceType;
        self.selectedSource = selectedSource == nil ? [NSMutableArray arrayWithCapacity:1] : selectedSource;
        self.showShot = showShot;
        self.allowCrop = allowCrop;
        self.navigationBar.barTintColor = kBarTintColor;
        self.navigationBar.tintColor = kTintColor;
        self.navigationBar.translucent = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setCropScale:(CGFloat)cropScale {
    _cropScale = cropScale;
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            picker.cropScale = _cropScale;
            break;
        }
    }
}

- (void)setMaxVideoDuration:(NSUInteger)maxVideoDuration {
    _maxVideoDuration = maxVideoDuration;
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            picker.maxVideoDuration = _maxVideoDuration;
            break;
        }
    }
}

- (void)setDirectEdit:(BOOL)directEdit {
    _directEdit = directEdit;
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            picker.directEdit = _directEdit;
            break;
        }
    }
}

- (void)setPreviewDelete:(BOOL)previewDelete {
    _previewDelete = previewDelete;
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            picker.previewDelete = _previewDelete;
            break;
        }
    }
}

- (void)setForcedCrop:(BOOL)forcedCrop {
    _forcedCrop = forcedCrop;
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            picker.forcedCrop = _forcedCrop;
            break;
        }
    }
}

- (void)configSectionInserts:(UIEdgeInsets)inserts cellSpace:(NSUInteger)cellSpace numOfLineCells:(NSUInteger)num {
    for (UIViewController * itemVC in self.viewControllers) {
        if ([itemVC isKindOfClass:[EJImagePickerVC class]]) {
            EJImagePickerVC * picker = (EJImagePickerVC *)itemVC;
            [picker configSectionInserts:inserts cellSpace:cellSpace numOfLineCells:num];
            break;
        }
    }
}

#pragma mark - EJImagePickerDelegate
- (void)ej_imagePickerDidSelected:(NSMutableArray *)source {
    if ([self.pickerDelegate respondsToSelector:@selector(ej_imagePickerVC:didSelectedSource:)]) {
        [self.pickerDelegate ej_imagePickerVC:self didSelectedSource:source];
    }
}

@end
