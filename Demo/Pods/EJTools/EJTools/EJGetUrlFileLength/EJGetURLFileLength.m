//
//  EJGetURLFileLength.m
//  TrainIOS
//
//  Created by Lius on 2017/9/26.
//  Copyright © 2017年 zaichengzhang. All rights reserved.
//

#import "EJGetURLFileLength.h"

@implementation EJGetURLFileLength

+ (instancetype)defaultFileLength {
    static EJGetURLFileLength *fileLength;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        fileLength = [[EJGetURLFileLength alloc] init];
//    });
    return fileLength;
}

- (void)getUrlFileLength:(NSString *)url withResultBlock:(FileLength)block {
    _block = [block copy];
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [mURLRequest setHTTPMethod:@"HEAD"];
    mURLRequest.timeoutInterval = 5.0;
    NSURLConnection *URLConnection = [NSURLConnection connectionWithRequest:mURLRequest delegate:self];
    [URLConnection start];
}

- (void)getLocalPathFileLength:(NSString *)filePath created:(UInt32)created withResultBlock:(void(^)(long long length, NSString *status))block {

    NSFileManager *filemanager = [NSFileManager defaultManager];

    if ([filemanager fileExistsAtPath:filePath]) {
        long long length = [[filemanager attributesOfItemAtPath:filePath error:nil] fileSize];
        if (block) {
            block(length, @"已下载");
        }
    }
    else {
        if (block) {
            block(0, @"未下载");
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSDictionary *dict = [(NSHTTPURLResponse *)response allHeaderFields];
    NSNumber *length = [dict objectForKey:@"Content-Length"];
    [connection cancel];
    if (_block) {
        _block([length longLongValue], nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"获取文件大小失败：%@",error);
    if (_block) {
        _block(0, error);
    }
    [connection cancel];
}

@end
