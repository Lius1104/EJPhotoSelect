//
//  EJProgressHUD.m
//  EJiangOSbeta
//
//  Created by Lius on 2017/4/5.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "EJProgressHUD.h"
#import <YYKit/UIColor+YYAdd.h>

@implementation EJProgressHUD

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
        self.removeFromSuperViewOnHide = YES;
        self.contentColor = UIColorHex(ffffff);
        self.bezelView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

+ (instancetype)ej_showHUDAddToView:(UIView *)view animated:(BOOL)animated {
    EJProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

+ (void)showAlert:(NSString *)text forView:(UIView *)view {
#ifdef DEBUG
    //    NSAssert(![text containsString:@"404"], @"api 404.");
    //    NSAssert(![text containsString:@"不支持的 URL"], @"api 不支持的 URL.");
    //    NSAssert(![text containsString:@"服务器"], @"api 服务器发生错误.");
    if ([text containsString:@"404"]) {
        NSLog(@"api 404.");
    }
    if ([text containsString:@"不支持的 URL"]) {
        NSLog(@"api 不支持的 URL.");
    }
    if ([text containsString:@"服务器"]) {
        NSLog(@"api 服务器发生错误.");
    }
    if ([text containsString:@"格式"]) {
        NSLog(@"api 服务器发生错误.");
    }
    if ([text containsString:@"URL"]) {
        NSLog(@"api 服务器发生错误.");
    }
#else
#endif
    EJProgressHUD *hud = [EJProgressHUD ej_showHUDAddToView:view animated:YES];
    hud.label.text = text;
    hud.mode = MBProgressHUDModeText;
    [hud hideAnimated:YES afterDelay:1.5f];
}

+ (void)showConfirmAlert:(NSString *)text {
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil
                                                   message:text
                                                  delegate:self
                                         cancelButtonTitle:@"确定"
                                         otherButtonTitles:nil];
    [alert show];
}

@end
