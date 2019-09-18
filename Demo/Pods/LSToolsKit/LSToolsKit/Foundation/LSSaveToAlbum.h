//
//  LSSaveToAlbum.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/17.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^SuccessBlock)(NSString * assetLocalId);

typedef void(^FailureBlock)(NSError * error);

@interface LSSaveToAlbum : NSObject

+ (LSSaveToAlbum *)mainSave;

- (void)configCustomAlbumName:(NSString *)customName;

- (void)saveImage:(UIImage *)image successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure;

- (void)saveImageWithUrl:(NSURL *)imgUrl successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure;

- (void)saveVideoWithUrl:(NSURL *)videoUrl successBlock:(SuccessBlock)block failureBlock:(FailureBlock)failure;

@end
