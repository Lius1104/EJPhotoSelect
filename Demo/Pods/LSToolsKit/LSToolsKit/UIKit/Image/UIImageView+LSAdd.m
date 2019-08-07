//
//  UIImageView+LSAdd.m
//  LSToolsKitDemo
//
//  Created by LiuShuang on 2019/6/10.
//  Copyright © 2019 刘爽. All rights reserved.
//

#import "UIImageView+LSAdd.h"

@implementation UIImageView (LSAdd)

+ (CGSize)ls_singleImageSizeWithUrlStr:(NSString *)urlStr withMaxWidth:(CGFloat)maxW ratio:(CGFloat)ratio {
    CGFloat maxH = ceil(maxW / ratio);
    CGSize imgSize = [self ls_originalWebImageSizeWithURLStr:urlStr];
    
    CGFloat scale1 = imgSize.width / maxW;
    CGFloat scale2 = imgSize.height / maxH;
    CGFloat scale = scale1 >= scale2 ? scale1 : scale2;
    CGFloat hopeW = ceil(imgSize.width / scale);
    CGFloat hopeH = ceil(imgSize.height / scale);
    
    if (isnan(hopeW)) {
        hopeW = ceil(maxW);
    }
    if (isinf(hopeW)) {
        hopeW = ceil(maxW);
    }
    
    if (hopeW < ceil(maxW / 2.f)) {
        hopeW = ceil(maxW / 2.f);
        scale = ceil(imgSize.width / hopeW);
        hopeH = ceil(imgSize.height / scale);
    }
    
    if (isnan(hopeH)) {
        hopeH = ceil(maxH);
    }
    if (isinf(hopeH)) {
        hopeH = ceil(maxH);
    }
    if (hopeH > maxH) {
        hopeH = ceil(maxH);
    }
    CGSize size = CGSizeMake(hopeW, hopeH);
    return size;
}

+ (CGSize)ls_originalWebImageSizeWithURLStr:(NSString *)urlStr {
    return [UIImageView getImageSizeWithURL:urlStr];
}

+ (CGSize)getImageSizeWithURL:(NSString *)urlStr {
    if (!urlStr) {
        return CGSizeZero;
    }
    if ([urlStr containsString:@"(null)"]) {
        return CGSizeZero;
    }
    NSURL * url = nil;
    if ([urlStr isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlStr];
    }
    if ([urlStr isEqualToString:@"http://file.zaichengzhang.netplaceholder.png"]) {
        NSLog(@" low %@", [NSDate date]);
    }
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        //以下是对手机32位、64位的处理
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            CFRelease(imageProperties);
        }
        
        CFRelease(imageSourceRef);
    }
    return CGSizeMake(width, height);
}

@end
