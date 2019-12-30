//
//  EJGetURLFileLength.h
//  TrainIOS
//
//  Created by Lius on 2017/9/26.
//  Copyright © 2017年 zaichengzhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FileLength)(long long length, NSError *error);

@interface EJGetURLFileLength : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, copy) FileLength block;

+ (instancetype)defaultFileLength;

- (void)getUrlFileLength:(NSString *)url withResultBlock:(FileLength)block;

- (void)getLocalPathFileLength:(NSString *)filePath created:(UInt32)created withResultBlock:(void(^)(long long length, NSString *status))block;

@end
