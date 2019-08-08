//
//  UIViewController+EJAdd.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/8/7.
//  Copyright © 2019 LiuShuang. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (EJAdd)

- (void)ej_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion API_AVAILABLE(ios(5.0));

@end

NS_ASSUME_NONNULL_END
