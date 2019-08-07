//
//  EJImageManager.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface EJImageManager : NSObject

+ (instancetype)manager;

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, strong) PHImageRequestOptions * imageOptions;

- (BOOL)authorizationStatusAuthorized;
- (void)requestAuthorizationWithCompletion:(void (^)(void))completion;

@end

//NS_ASSUME_NONNULL_END
