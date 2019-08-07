//
//  EJWebImgCache.m
//  IOSParents
//
//  Created by Lius on 2017/8/10.
//  Copyright © 2017年 ejiang. All rights reserved.
//

#import "EJWebImgCache.h"


@implementation EJWebImgCache

+ (void)ej_setImageWithCarrier:(UIImageView *)imgView placeholder:(UIImage *)placeholder strURL:(NSString *)strURL useMode:(EJWebImgUseMode)useMode {
    BOOL appendW = NO;
    if (placeholder == nil) {
        placeholder = [self defaultPlaceholder:useMode];
        appendW = NO;
    }
    [imgView ej_setImageWithStringURL:strURL placeholperImage:placeholder appendWidth:appendW];
}

+ (void)ej_setImageWithCarrier:(UIImageView *)imgView placeholder:(UIImage *)placeholder strURL:(NSString *)strURL useMode:(EJWebImgUseMode)useMode completed:(EJImageCompletionBlock)webImgCompletedBlock {
    BOOL appendW = NO;
    if (placeholder == nil) {
        placeholder = [self defaultPlaceholder:useMode];
        appendW = NO;
    }
    if ([strURL length]) {
        [imgView ej_setImageWithStringURL:strURL placeholperImage:placeholder appendWidth:appendW completed:^(UIImage * image, NSError * error, NSURL * imageURL) {
            if (webImgCompletedBlock != nil) {
                webImgCompletedBlock(image, error, imageURL);
            }
        }];
    } else {
        imgView.image = placeholder;
    }
}

/**
 默认占位图

 @param useMode EJWebImgUseMode
 @return UIImage
 */
+ (UIImage *)defaultPlaceholder:(EJWebImgUseMode)useMode {
    UIImage *placeholder;
    /**
     * 定义不同 类型的默认占位图 可定义一下：
     * EJWebImgUseModeHeader => kEJWebHeaderBlank
     * EJWebImgUseModeChat => kEJWebChatBlank
     * EJWebImgUseModeBanner => kEJWebBannerBlank
     * EJWebImgUseModeSmall => kEJWebSmallBlank
     * EJWebImgUseModeNormal => kEJWebNormalBlank
     * EJWebImgUseModeLarge => kEJWebLargeBlank
     * EJWebImgUseMode3x4 => kEJWeb3x4Blank
     * EJWebImgUseMode4x3 => kEJWeb4x3Blank
     * EJWebImgUseMode16x9 => kEJWeb16x9Blank
     * EJWebImgUseMode9x16 => kEJWeb9x16Blank
     * EJWebImgUseModeOther => kEJWebOtherBlank
     */
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"EJTools" ofType:@"bundle"]];
    
    switch (useMode) {
        case EJWebImgUseModeHeader: {
#if !defined(kEJWebHeaderBlank)
            placeholder = [UIImage imageNamed:@"ej_defaultPhoto" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
#else
            placeholder = [UIImage imageNamed:kEJWebHeaderBlank];
#endif
        }
            break;
        case EJWebImgUseModeChat: {
#if !defined(kEJWebChatBlank)
            placeholder = [UIImage imageNamed:@"ej_imGroup" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
#else
            placeholder = [UIImage imageNamed:kEJWebChatBlank];
#endif
        }
            break;
        case EJWebImgUseModeBanner: {
#if !defined(kEJWebBannerBlank)
            placeholder = [UIImage imageNamed:@"ej_banner_loading" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
#else
            placeholder = [UIImage imageNamed:kEJWebBannerBlank];
#endif
        }
            break;
        case EJWebImgUseModeOther: {
#if !defined(kEJWebOtherBlank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWebOtherBlank];
#endif
        }
            break;
        case EJWebImgUseModeSmall: {
#if !defined(kEJWebSmallBlank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWebSmallBlank];
#endif
        }
            break;
        case EJWebImgUseModeNormal: {
#if !defined(kEJWebNormalBlank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWebNormalBlank];
#endif
        }
            break;
        case EJWebImgUseModeLarge: {
#if !defined(kEJWebLargeBlank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWebLargeBlank];
#endif
        }
            break;
        case EJWebImgUseMode3x4: {
#if !defined(kEJWeb3x4Blank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWeb3x4Blank];
#endif
        }
            break;
        case EJWebImgUseMode4x3: {
#if !defined(kEJWeb4x3Blank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWeb4x3Blank];
#endif
        }
            break;
        case EJWebImgUseMode16x9: {
#if !defined(kEJWeb16x9Blank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWeb16x9Blank];
#endif
        }
            break;
        case EJWebImgUseMode9x16: {
#if !defined(kEJWeb9x16Blank)
            placeholder = nil;
#else
            placeholder = [UIImage imageNamed:kEJWeb9x16Blank];
#endif
        }
            break;
    }
    return placeholder;
}

@end
