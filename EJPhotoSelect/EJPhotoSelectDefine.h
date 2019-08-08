//
//  EJPhotoSelectDefine.h
//  EJPhotoBrowser
//
//  Created by LiuShuang on 2019/8/8.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#ifndef EJPhotoSelectDefine_h
#define EJPhotoSelectDefine_h


#define kToolsIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kToolsIs_iPhoneX (kScreenWidth >=375.0f && kScreenHeight >=812.0f && kToolsIs_iphone)
#define kToolsBottomSafeHeight (CGFloat)(kToolsIs_iPhoneX?(34.0):(0))

#define kToolsStatusHeight                [[UIApplication sharedApplication] statusBarFrame].size.height

#define kToolsNavStatusHeight             (kToolsStatusHeight + 44)

#endif /* EJPhotoSelectDefine_h */
