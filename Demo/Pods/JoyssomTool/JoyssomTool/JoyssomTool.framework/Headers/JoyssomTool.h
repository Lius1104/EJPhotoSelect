//
//  JoyssomTool.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<JoyssomTool/JoyssomTool.h>)
//! Project version number for JoyssomTool.
FOUNDATION_EXPORT double JoyssomToolVersionNumber;

//! Project version string for JoyssomTool.
FOUNDATION_EXPORT const unsigned char JoyssomToolVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JoyssomTool/PublicHeader.h>

#import <JoyssomTool/API.h>
#import <JoyssomTool/APNsConfig.h>
#import <JoyssomTool/EJFileResponseModel.h>
#import <JoyssomTool/EJResponseModel.h>

#import <JoyssomTool/NSDictionary+EJAdd.h>
#import <JoyssomTool/UIFont+EJAdd.h>
#import <JoyssomTool/UIView+EJAdaptation.h>
#import <JoyssomTool/UIView+EJAnimation.h>
#import <JoyssomTool/NSDate+EJAdd.h>
#import <JoyssomTool/NSDateFormatter+EJAdd.h>
#import <JoyssomTool/NSString+EJNetwork.h>
#import <JoyssomTool/NSString+EJAdd.h>
#import <JoyssomTool/UIDevice+EJAdd.h>

#else

#import "API.h"
#import "APNsConfig.h"
#import "EJFileResponseModel.h"
#import "EJResponseModel.h"

#import "NSDictionary+EJAdd.h"
#import "UIFont+EJAdd.h"

#import "UIView+EJAdaptation.h"
#import "UIView+EJAnimation.h"

#import "NSDate+EJAdd.h"
#import "NSDateFormatter+EJAdd.h"
#import "NSString+EJNetwork.h"
#import "NSString+EJAdd.h"
#import "UIDevice+EJAdd.h"

#endif
