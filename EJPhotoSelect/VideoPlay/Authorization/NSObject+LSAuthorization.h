//
//  NSObject+LSAuthorization.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/17.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PhotoLibraryUsageAuthBlock)(PHAuthorizationStatus status);

@interface NSObject (LSAuthorization)

+ (void)judgeAppPhotoLibraryUsageAuth:(PhotoLibraryUsageAuthBlock)authBlock;

@end
