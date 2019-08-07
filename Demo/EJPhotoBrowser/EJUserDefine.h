//
//  EJUserDefine.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/6/18.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#ifndef EJUserDefine_h
#define EJUserDefine_h

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX kScreenWidth >=375.0f && kScreenHeight >=812.0f&& kIs_iphone
#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))

#define TabBarHeight                (49 + kBottomSafeHeight)

#define StatusHeight                [[UIApplication sharedApplication] statusBarFrame].size.height

#define NavHeight                   self.navigationController.navigationBar.frame.size.height

#define NavStatusHeight             (StatusHeight + 44)

#define kShotVideoMaximumSecond     (30 * 60)

#define kBarTintColor               UIColorHex(ffffff)
#define kTintColor                  UIColorHex(333333)
#define kMajorColor                 UIColorHex(509ef0)
#define kMinorColor                 UIColorHex(eff5fb)
#define kLineColor                  UIColorHex(dadada)

#endif /* EJUserDefine_h */
