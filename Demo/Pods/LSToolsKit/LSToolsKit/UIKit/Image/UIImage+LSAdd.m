//
//  UIImage+LSAdd.m
//  LSKitDemo
//
//  Created by Lius on 2017/5/5.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import "UIImage+LSAdd.h"

NSData * __nullable LSImageJPEGRepresentation(UIImage * __nonnull image, CGFloat compressionQuality) {
    if (image == nil) {
        return nil;
    }
    NSData * imageData = UIImageJPEGRepresentation(image, compressionQuality);
    if (imageData == nil) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
        
//        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0); // 0.0 for scale means "correct scale for device's main screen".
//        CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width, image.size.height)); // cropping happens here.
//        UIImage * newImage = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:image.imageOrientation]; // create cropped UIImage.
//        [newImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)]; // the actual scaling happens here, and orientation is taken care of automatically.
//        CGImageRelease(sourceImg);
//        newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        imageData = UIImageJPEGRepresentation(newImage, compressionQuality);
    }
    
    return imageData;
}

@implementation UIImage (LSAdd)

- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    UIImage *normalizedImage;
    @try {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        [self drawInRect:(CGRect){0, 0, self.size}];
        normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } @catch (NSException *exception) {
        return self;
    }
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
//    [self drawInRect:(CGRect){0, 0, self.size}];
//    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    return normalizedImage == nil ? self : normalizedImage;
    
//    UIImage *image;
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale); // 0.0 for scale means "correct scale for device's main screen".
//    CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], (CGRect){0, 0, self.size}); // cropping happens here.
//    image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.
//    [image drawInRect:(CGRect){0, 0, self.size}]; // the actual scaling happens here, and orientation is taken care of automatically.
//    CGImageRelease(sourceImg);
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
}

#pragma mark - [---压缩---]
//将UIImage缩放到指定大小尺寸：
+ (UIImage *)imageCompress:(UIImage*)imge scaleToSize:(CGSize)size {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [imge drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

//根据图片的大小限定在limitToSize的宽高内，进行等比例压缩返回图片
+ (UIImage *)imageCompress:(UIImage *)image limitToSize:(CGSize)limitSize {
    if (nil == image)
    {
        return nil;
    }
    if (image.size.width<limitSize.width && image.size.height<limitSize.height)
    {
        return image;
    }
    CGSize size = [self fitsize:image.size limitToSize:limitSize];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [image drawInRect:rect];
    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newing;
}

/**
 *  压缩图片到指定范围内（符合原尺寸比例并且只有宽或高在指定的边缘范围内即可）
 */
+ (UIImage *)imageCompress:(UIImage *)image edgeSize:(CGSize)edgeSize {
    if (nil == image) {
        return nil;
    }
    CGSize original = image.size;
    CGFloat scale1 = original.width / edgeSize.width;
    CGFloat scale2 = original.height / edgeSize.height;
    CGFloat scale = scale1 <= scale2 ? scale1 : scale2;
    CGFloat width = 0;
    CGFloat height = 0;
    if (scale <= 1) {
        return image;
    } else {
        width = ceil(original.width / scale);
        height = ceil(original.height / scale);
    }
    CGSize newSize = CGSizeMake(width, height);
    CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
//    UIGraphicsBeginImageContext(newSize);
//    [image drawInRect:rect];
//    UIImage *newing = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return newing;
    
    UIImage *resultImage;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0); // 0.0 for scale means "correct scale for device's main screen".
//    CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, original.width, original.height)); // cropping happens here.
    CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width, image.size.height));
//    image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:image.imageOrientation]; // create cropped UIImage.
    image = [UIImage imageWithCGImage:sourceImg];
    [image drawInRect:rect]; // the actual scaling happens here, and orientation is taken care of automatically.
    CGImageRelease(sourceImg);
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) ==NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {

            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    return newImage ;
}

- (NSData *)imageCompressToLimitBitSize:(CGFloat)limitBitSize {
//    CGFloat compression = 0.9;
//    NSData *imageData = LSImageJPEGRepresentation(self, compression);
//    NSLog(@"%f", (double)[imageData length]);
//    if (@available(iOS 10.0, *)) {
//        CIImage *ciImage = [CIImage imageWithData:imageData];
//        CIContext *context = [CIContext context];
//        imageData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
//    }
    
//    NSLog(@"%f", (double)[imageData length]);
//    while ([imageData length] > limitBitSize/* && compression > maxCompression*/) {
//        compression *= 0.9;
//        NSData * data = LSImageJPEGRepresentation(self, compression);
//        if ([data length] == [imageData length]) {
//            imageData = data;
//            break;
//        } else {
//            imageData = data;
//        }
//        NSLog(@"%f", (double)[imageData length]);
//    }
//    return imageData;
    
    CGFloat compression = 1;
    NSData * imageData = UIImageJPEGRepresentation(self, compression);
    if (@available(iOS 10.0, *)) {
        CIImage *ciImage = [CIImage imageWithData:imageData];
        CIContext *context = [CIContext context];
        imageData = [context JPEGRepresentationOfImage:ciImage colorSpace:ciImage.colorSpace options:@{}];
    }
    UIImage * newImage = [UIImage imageWithData:imageData];
    if (imageData.length < limitBitSize) return imageData;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        imageData = UIImageJPEGRepresentation(newImage, compression);
        if (imageData.length < limitBitSize * 0.9) {
            min = compression;
        } else if (imageData.length > limitBitSize) {
            max = compression;
        } else {
            break;
        }
    }
    return imageData;
}

+ (CGSize)fitsize:(CGSize)thisSize limitToSize:(CGSize)lsize {
    if(thisSize.width == 0 && thisSize.height == 0)
        return CGSizeMake(0, 0);
    CGFloat wscale = thisSize.width/lsize.width;
    CGFloat hscale = thisSize.height/lsize.height;
    CGFloat scale = (wscale>hscale)?wscale:hscale;
    CGSize newSize = CGSizeMake(thisSize.width/scale, thisSize.height/scale);
    return newSize;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

+ (UIImage *)getFirstThumbImage:(NSURL *)videoURL {

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];

    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    gen.appliesPreferredTrackTransform = YES;

    CMTime time = CMTimeMakeWithSeconds(0.0, 600);

    NSError *error = nil;

    CMTime actualTime;

    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];

    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];

    CGImageRelease(image);

    return thumb;
}

+ (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size backgroundColor:(UIColor *)bgColor {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [bgColor set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    CGSize titleSize = [string boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    titleSize.width = ceil(titleSize.width);
    titleSize.height = ceil(titleSize.height);
    CGFloat x = (size.width - titleSize.width) / 2.f;
    CGFloat y = (size.height - titleSize.height) / 2.f;
    [string drawInRect:CGRectMake(x, y, titleSize.width, titleSize.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 截取部分图像
- (UIImage *)subImageWithRect:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

#pragma mark - 等比例缩放
- (UIImage *)scaleToSize:(CGSize)size {
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height * 1.0 / height;
    float horizontalRadio = size.width * 1.0 / width;
    float radio = 1;
    
    if(verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    } else {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width * radio;
    height = height * radio;
    int xPos = (size.width - width) / 2;
    int yPos = (size.height - height) / 2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

#pragma mark - 图片拼接
//配合SDWebImage根据图片URL获取图片(有缓存则获取缓存的图片，没有则网络链接获取)

+ (UIImage *)imageWithUrlString:(NSString *)imageUrl {
    UIImageView * imageView = [[UIImageView alloc] init];
    NSURL * url = [NSURL URLWithString:imageUrl];
    [imageView sd_setImageWithURL:url placeholderImage:nil];
    UIImage * image = imageView.image;
    if (image == nil) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
    }
    return image;
}

//传入图片数组即可（如果是读取链接图片可配合SDWebImage使用上面的方法获取图片再添加入数组）
//拼接完成返回一张图片
+ (UIImage *)combine:(NSArray<UIImage *> *)images {
    CGSize offScreenSize = CGSizeMake(200, 200);

    UIGraphicsBeginImageContext(offScreenSize);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);//图片背景色
    CGContextFillRect(context, CGRectMake(0, 0, 200, 200));
    //确定拼接图片的宽度
    CGFloat imageWidth = [self generateImageWidthWithImageCount:images.count];
    switch (images.count) {
        case 2: {
            CGFloat row_1_origin_y = (200 - imageWidth) / 2;
            [self generatorMatrix:images beginOriginY:row_1_origin_y];
        }
            break;
        case 3: {
            CGFloat row_1_origin_y = (200 - imageWidth * 2) / 3;

            UIImage* image_1 = images[0];
            CGRect rect_1 = CGRectMake((200 - imageWidth) / 2, row_1_origin_y, imageWidth, imageWidth);
            [image_1 drawInRect:rect_1];
            [self generatorMatrix:images beginOriginY:row_1_origin_y + imageWidth + 0];
        }
            break;
        case 4: {
            CGFloat row_1_origin_y = (200 - imageWidth * 2) / 3;
            [self generatorMatrix:images beginOriginY:row_1_origin_y];
        }
            break;
        case 5: {
            CGFloat row_1_origin_y = (200 - imageWidth * 2 - 0) / 2;

            UIImage* image_1 = images[0];
            CGRect rect_1 = CGRectMake((200 - 2 * imageWidth - 0) / 2, row_1_origin_y, imageWidth, imageWidth);
            [image_1 drawInRect:rect_1];

            UIImage* image_2 = images[1];
            CGRect rect_2 = CGRectMake(rect_1.origin.x + imageWidth + 0, row_1_origin_y, imageWidth, imageWidth);
            [image_2 drawInRect:rect_2];

            [self generatorMatrix:images beginOriginY:row_1_origin_y + imageWidth + 0];
        }
            break;
        case 6: {
            CGFloat row_1_origin_y = (200 - imageWidth * 2 - 0) / 2;

            [self generatorMatrix:images beginOriginY:row_1_origin_y];
        }
            break;
        case 7: {
            CGFloat row_1_origin_y = (200 - imageWidth * 3) / 4;

            UIImage* image_1 = images[0];
            CGRect rect_1 = CGRectMake((200 - imageWidth) / 2, row_1_origin_y, imageWidth, imageWidth);
            [image_1 drawInRect:rect_1];
            [self generatorMatrix:images beginOriginY:row_1_origin_y + imageWidth + 0];
        }
            break;
        case 8: {
            CGFloat row_1_origin_y = (200 - imageWidth * 3) / 4;

            UIImage* image_1 = images[0];
            CGRect rect_1 = CGRectMake((200 - 2 * imageWidth - 0) / 2, row_1_origin_y, imageWidth, imageWidth);
            [image_1 drawInRect:rect_1];
            UIImage* image_2 = images[1];
            CGRect rect_2 = CGRectMake(rect_1.origin.x + imageWidth + 0, row_1_origin_y, imageWidth, imageWidth);
            [image_2 drawInRect:rect_2];
            [self generatorMatrix:images beginOriginY:row_1_origin_y + imageWidth + 0];
        }
            break;
        case 9: {
            CGFloat row_1_origin_y = (200 - imageWidth * 3) / 4;
            [self generatorMatrix:images beginOriginY:row_1_origin_y];
        }
            break;
        default:
            break;
    }
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return imagez;
}

+ (void)generatorMatrix:(NSArray *)images beginOriginY:(CGFloat)beginOriginY {
    int count = (int)images.count;

    int cellCount;
    int maxRow;
    int maxColumn;
    int ignoreCountOfBegining;

    if (count <= 4)
    {
        maxRow = 2;
        maxColumn = 2;
        ignoreCountOfBegining = count % 2;
        cellCount = 4;
    }
    else
    {
        maxRow = 3;
        maxColumn = 3;
        ignoreCountOfBegining = count % 3;
        cellCount = 9;
    }
    CGFloat imageWidth = [self generateImageWidthWithImageCount:images.count];

    for (int i = 0; i < cellCount; i++) {
        if (i > images.count - 1) break;
        if (i < ignoreCountOfBegining) continue;

        int row = floor((float)(i - ignoreCountOfBegining) / maxRow);
        int column = (i - ignoreCountOfBegining) % maxColumn;

        CGFloat origin_x = 0 + imageWidth * column + 0 * column;
        CGFloat origin_y = beginOriginY + imageWidth * row + 0 * row;

        CGRect rect = CGRectZero;
        rect = CGRectMake(origin_x, origin_y, imageWidth, imageWidth);
        [images[i] drawInRect:rect];
    }
}

+ (CGFloat)generateImageWidthWithImageCount:(NSInteger)count {
    CGFloat sideLength = 0.0f;

    if (count >= 2 && count <= 4) {
        sideLength = (200 - 0 * 3) / 2;
    } else {
        sideLength = (200 - 0 * 4) / 3;
    }

    return sideLength;
}

@end
