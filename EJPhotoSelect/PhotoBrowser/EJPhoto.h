//
//  EJPhoto.h
//  EJPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "EJPhotoProtocol.h"

// This class models a photo/image and it's caption
// If you want to handle photos, caching, decompression
// yourself then you can simply ensure your custom data model
// conforms to EJPhotoProtocol
@interface EJPhoto : NSObject <EJPhoto>

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL emptyImage;
@property (nonatomic) BOOL isVideo;

@property (nonatomic, strong, readonly) PHAsset *asset;
@property (nonatomic, strong) NSURL *photoURL;

+ (EJPhoto *)photoWithImage:(UIImage *)image;
+ (EJPhoto *)photoWithURL:(NSURL *)url;
+ (EJPhoto *)photoWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (EJPhoto *)videoWithURL:(NSURL *)url; // Initialise video with no poster image

- (id)init;
- (id)initWithImage:(UIImage *)image;
- (id)initWithURL:(NSURL *)url;
- (id)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (id)initWithVideoURL:(NSURL *)url;

@end

