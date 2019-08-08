//
//  API.h
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/20.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface API : NSObject

@property (nonatomic, copy) NSString * appId;

@property (nonatomic, copy) NSString * secretKey;

@property (nonatomic, assign) NSInteger gapTime;

@property (nonatomic, copy) NSString * apiUrl;

@property (nonatomic, copy) NSString * fileUrl;

+ (instancetype)sharedApi;

@end

#define kAppId          [API sharedApi].appId
#define kSecretKey      [API sharedApi].secretKey

#define kGapTime        [API sharedApi].gapTime

#define kApiUrl         [API sharedApi].apiUrl
#define kFileUrl        [API sharedApi].fileUrl

NS_ASSUME_NONNULL_END
