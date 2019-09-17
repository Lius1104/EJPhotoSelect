//
//  EJAssetLinkLocal.h
//  EJPhotoBrowser
//
//  Created by 刘爽 on 2019/8/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface EJAssetLinkLocal : NSObject

@property (nonatomic, strong) PHAsset * asset;

/// 编辑后的本地沙盒路径
@property (nonatomic, copy) NSString * localPath;

/// 本地沙盒路径的封面
@property (nonatomic, strong) UIImage * coverImage;

+ (NSString *)rootPath;

@end

//NS_ASSUME_NONNULL_END
