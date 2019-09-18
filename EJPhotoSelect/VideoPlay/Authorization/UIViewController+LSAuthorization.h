//
//  UIViewController+LSAuthorization.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


typedef void(^PhotoLibraryUsageAuthBlock)(PHAuthorizationStatus status);

@interface UIViewController (LSAuthorization)

- (void)judgeAppPhotoLibraryUsageAuth:(PhotoLibraryUsageAuthBlock)authBlock;

- (void)deniedAuthAlertTitle:(NSString *)title authBlock:(PhotoLibraryUsageAuthBlock)authBlock;

@end
