//
//  UIViewController+EJAdd.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/8/7.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "UIViewController+EJAdd.h"


@implementation UIViewController (EJAdd)

- (void)ej_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion {
    if (@available(iOS 13.0, *)) {
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
