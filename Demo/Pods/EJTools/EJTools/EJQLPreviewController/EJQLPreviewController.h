//
//  EJQLPreviewController.h
//  EJiangOSbeta
//
//  Created by 刘爽 on 2019/9/23.
//  Copyright © 2019 Joyssom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EJQLPreviewConfig : NSObject

+ (instancetype)sharedQLPreview;

/// 进度条颜色
@property (nonatomic, strong) UIColor * progressColor;
/// 文件下载存储路径
@property (nonatomic, copy) NSString * targetPath;

@end

@interface EJQLPreviewController : UIViewController

@property (nonatomic, strong) NSURL * Url;

/// 打开本地 文件
/// @param url  文件路径，具体到文件
- (instancetype)initWithLocalUrl:(NSURL *)url;

/// 打开网络文件（先下载到本地）
/// @param filePath 文件链接
/// @param fileSize 文件大小，不知道大小传0，知道值的话尽量传值，可以节省一步网络请求
- (instancetype)initWithFilePath:(NSString *)filePath fileSize:(NSInteger)fileSize;

/// 打开网络文件（先下载到本地）不知道文件大小
/// @param filePath 文件链接
- (instancetype)initWithFilePath:(NSString *)filePath;

/// 文件名称 self.title 赋值用
@property (nonatomic, copy) NSString * fileName;

/// 进度条颜色
@property (nonatomic, strong) UIColor * progressColor;

/// 文件下载存储路径
@property (nonatomic, copy) NSString * targetPath;

@end

NS_ASSUME_NONNULL_END
