//
//  UIImageView+EJWebCache.m
//  IOSParents
//
//  Created by Lius on 2017/8/9.
//  Copyright © 2017年 Joyssom. All rights reserved.
//

#import "UIImageView+EJWebCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYKit/YYKit.h>

@implementation UIImageView (EJWebCache)

/**
 动态单张图片显示大小

 @param urlStr 网络图片链接
 @param maxW 最大允许的宽度
 @param ratio 宽高比
 @return 最终在屏幕上显示的imageview的size
 */
+ (CGSize)singleImageSizeWithUrlStr:(NSString *)urlStr withMaxWidth:(CGFloat)maxW ratio:(CGFloat)ratio {
    CGFloat maxH = ceil(maxW / ratio);
    CGSize imgSize = [self originalWebImageSizeWithURLStr:urlStr];
    
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

+ (CGSize)originalWebImageSizeWithURLStr:(NSString *)urlStr {
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

+ (CGSize)downloadJpgImage:(NSString *)strUrl {
    if ([strUrl length] == 0) {
        return CGSizeZero;
    }
    NSURL * url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString * pathExt = [url.pathExtension lowercaseString];
    if ([pathExt rangeOfString:@"png"].location != NSNotFound) {
        return [self pngImageSizeWithHeaderData:request];
    } else if ([pathExt rangeOfString:@"jpg"].location != NSNotFound || [pathExt rangeOfString:@"jpeg"].location != NSNotFound) {
        return [self jpgImageSizeWithHeaderData:request];
    } else {
        return CGSizeZero;
    }
}

+ (CGSize)pngImageSizeWithHeaderData:(NSMutableURLRequest *)request {
    [request setValue:@"bytes=16-23"forHTTPHeaderField:@"Range"];
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8) {
        int w1 =0, w2 =0, w3 =0, w4 =0;
        [data getBytes:&w1 range:NSMakeRange(0,1)];
        [data getBytes:&w2 range:NSMakeRange(1,1)];
        [data getBytes:&w3 range:NSMakeRange(2,1)];
        [data getBytes:&w4 range:NSMakeRange(3,1)];
        int w = (w1 <<24) + (w2 <<16) + (w3 <<8) + w4;
        int h1 =0, h2 =0, h3 =0, h4 =0;
        [data getBytes:&h1 range:NSMakeRange(4,1)];
        [data getBytes:&h2 range:NSMakeRange(5,1)];
        [data getBytes:&h3 range:NSMakeRange(6,1)];
        [data getBytes:&h4 range:NSMakeRange(7,1)];
        int h = (h1 <<24) + (h2 <<16) + (h3 <<8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

+ (CGSize)jpgImageSizeWithHeaderData:(NSMutableURLRequest *)request {
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

- (void)ej_setImageWithStringURL:(NSString *)strUrl targetSize:(CGSize)targetSize {
    NSString * urlString = [self handleUrlString:strUrl targetWidth:targetSize.width];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self sd_setImageWithURL:url completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
    }];
}

- (void)ej_setImageWithStringURL:(NSString *)strUrl placeholperImage:(UIImage *)placeholderImage targetSize:(CGSize)targetSize {
    NSString * urlString = [self handleUrlString:strUrl targetWidth:targetSize.width];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
    }];
}

- (void)ej_setImageWithStringURL:(NSString *)strUrl targetSize:(CGSize)targetSize completed:(EJImageCompletionBlock)completedBlock {
    NSString * urlString = [self handleUrlString:strUrl targetWidth:targetSize.width];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self sd_setImageWithURL:url completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
        if (completedBlock != nil) {
            completedBlock(image, error, imageURL);
        }
    }];
}

- (void)ej_setImageWithStringURL:(NSString *)strUrl placeholperImage:(UIImage *)placeholderImage targetSize:(CGSize)targetSize completed:(EJImageCompletionBlock)completedBlock {
    NSString * urlString = [self handleUrlString:strUrl targetWidth:targetSize.width];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
        if (completedBlock != nil) {
            completedBlock(image, error, imageURL);
        }
    }];
}


- (NSString *)handleUrlString:(NSString *)strUrl targetWidth:(CGFloat)targetWidth {
    if ([strUrl length] > 0) {
        NSURLComponents * components = [NSURLComponents componentsWithString:strUrl];
        BOOL needAppend = YES;
        for (NSURLQueryItem * item in components.queryItems) {
            if ([item.name isEqualToString:@"size"]) {
                needAppend = NO;
                break;
            }
        }
        if (needAppend) {
            NSString * appString = @"";
            if (targetWidth != 0) {
                CGFloat width = targetWidth * [UIScreen mainScreen].scale;
                if (width <= 120) {
                    appString = @"?size=s120";
                } else if (width <= 200) {
                    appString = @"?size=s200";
                } else if (width <= 480) {
                    appString = @"?size=m480";
                } else if (width <= 720) {
                    appString = @"?size=m720";
                } else {
                    appString = @"?size=lg1080";
                }
                return [strUrl stringByAppendingString:appString];
            } else {
                return strUrl;
            }
        } else {
            return strUrl;
        }
    }
    return @"";
}

#pragma mark - old
- (void)ej_setImageWithStringURL:(NSString *)strURL appendWidth:(BOOL)append completed:(EJImageCompletionBlock)completedBlock {
    if (append) {
        strURL = [strURL length] > 0 ? [strURL stringByAppendingString:[NSString stringWithFormat:@"?width=%d", (int)ceil(self.width)]] : @"";
    }
    NSURL *url = [NSURL URLWithString:strURL];
    [self sd_setImageWithURL:url completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
        if (completedBlock != nil) {
            completedBlock(image, error, imageURL);
        }
    }];
}

- (void)ej_setImageWithStringURL:(NSString *)strURL placeholperImage:(UIImage *)placeholderImage appendWidth:(BOOL)append {
    if (append) {
        strURL = [strURL length] > 0 ? [strURL stringByAppendingString:[NSString stringWithFormat:@"?width=%d", (int)ceil(self.width)]] : @"";
    }
    NSURL *url = [NSURL URLWithString:strURL];
    [self sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
    }];
}


- (void)ej_setImageWithStringURL:(NSString *)strURL placeholperImage:(UIImage *)placeholderImage appendWidth:(BOOL)append completed:(EJImageCompletionBlock)completedBlock {
    if (append) {
        strURL = [strURL length] > 0 ? [strURL stringByAppendingString:[NSString stringWithFormat:@"?width=%d", (int)ceil(self.width)]] : @"";
    }
    NSURL *url = [NSURL URLWithString:strURL];
    [self sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage * image, NSError * error, SDImageCacheType cacheType, NSURL * imageURL) {
        if (!self) return;
        if (image) {
            float width = image.size.width;
            float height = image.size.height;
            CGFloat scale = (height / width) / (self.height / self.width);
            if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            } else { // 高图只保留顶部
                if ((width / height) >= 0.5) {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    self.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
            }
        }
        if (completedBlock != nil) {
            completedBlock(image, error, imageURL);
        }
    }];
}


@end
