//
//  EJProgressHUD.h
//  EJiangOSbeta
//
//  Created by Lius on 2017/4/5.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface EJProgressHUD : MBProgressHUD

- (instancetype)initWithView:(UIView *)view;

+ (instancetype)ej_showHUDAddToView:(UIView *)view animated:(BOOL)animated;

+ (void)showAlert:(NSString *)text forView:(UIView *)view;

+ (void)showConfirmAlert:(NSString *)text;

@end
