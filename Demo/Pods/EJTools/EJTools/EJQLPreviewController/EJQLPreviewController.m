//
//  EJQLPreviewController.m
//  EJiangOSbeta
//
//  Created by 刘爽 on 2019/9/23.
//  Copyright © 2019 Joyssom. All rights reserved.
//

#import "EJQLPreviewController.h"
#import <QuickLook/QuickLook.h>
#import <YYKit/YYKit.h>
#import "EJWarningCardView.h"
#import "EJGetURLFileLength.h"

@implementation EJQLPreviewConfig

+ (instancetype)sharedQLPreview {
    static EJQLPreviewConfig * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[EJQLPreviewConfig alloc] init];
    });
    return config;
}

@end

@interface EJQLPreviewController ()<QLPreviewControllerDataSource, EJWarningCardViewDelegate, UIDocumentInteractionControllerDelegate, NSURLSessionDownloadDelegate>


@property (nonatomic, assign) NSInteger fileSize;

@property (nonatomic, copy) NSString * localPathStr;
@property (nonatomic, strong) NSURL * localFileUrl;

@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDownloadTask *download;

@property (nonatomic, copy) NSString * downloadPath;


#pragma mark - ui
@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UILabel * progressLabel;

@property (nonatomic, strong) UIBarButtonItem * rightItem;

@property (nonatomic, strong) EJWarningCardView * warningView;

@property (nonatomic, strong) UIDocumentInteractionController * document;

@end

@implementation EJQLPreviewController

- (void)dealloc {
    if (_download) {
//        [_download suspend];
        [_download cancel];
        _download = nil;
    }
}

- (instancetype)initWithLocalUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _Url = url;
        _localFileUrl = _Url;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath fileSize:(NSInteger)fileSize {
    if ([filePath length] == 0) {
        return nil;
    }
    NSString * path = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:path];
    if (url == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        _Url = url;
        _fileSize = fileSize;
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    if ([filePath length] == 0) {
        return nil;
    }
    NSString * path = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:path];
    if (url == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        _Url = url;
        _fileSize = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([_targetPath length] > 0) {
        _downloadPath = _targetPath;
    } else if ([[EJQLPreviewConfig sharedQLPreview].targetPath length] > 0) {
        _downloadPath = [EJQLPreviewConfig sharedQLPreview].targetPath;
    } else {
        _downloadPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    
    
    _rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ej_qlpreview_more"] style:UIBarButtonItemStyleDone target:self action:@selector(handleClickRightItem)];
    
    if ([_Url isFileURL]) {// 本地文件
        if (_fileName) {
            self.title = _fileName;
        } else {
            self.title = [_Url lastPathComponent];
        }
        
        [self configPreviewViews];
    } else {// 网络文件
        if (_fileName) {
            self.title = _fileName;
        } else {
            self.title = [[_Url.absoluteString componentsSeparatedByString:@"/"] lastObject];
        }
        //下载文件
        NSString * fileName = [[_Url.absoluteString componentsSeparatedByString:@"/"] lastObject];
        NSString * filePath = [_downloadPath stringByAppendingPathComponent:fileName];
        
        if (_fileSize == 0) {
            __weak typeof(self) weak_self = self;
            [[EJGetURLFileLength defaultFileLength] getUrlFileLength:_Url.absoluteString withResultBlock:^(long long length, NSError *error) {
                if (error) {
                    weak_self.fileSize = 0;
                } else {
                    weak_self.fileSize = length;
                }
                [weak_self handleServerFileWithPath:filePath];
                
            }];
        } else {
            [self handleServerFileWithPath:filePath];
        }
        
        
    }
}

//- (void)viewWillDisappear:(BOOL)animated {
//
//}

- (void)handleServerFileWithPath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self downloadFileIsExit:YES];
    } else {
        NSString * title;// = [NSString stringWithFormat:@"文件大小为%dkb，下载后可打开", (int)(_fileSize / 1000)];
        if (_fileSize > 0) {
            if (_fileSize / 1000 / 1000 > 0) {
                title = [NSString stringWithFormat:@"文件大小为%.2fMB，下载后可打开", (float)(_fileSize / (1000 * 1000.0))];
            } else if (_fileSize / 1000 > 0) {
                title = [NSString stringWithFormat:@"文件大小为%.2fKB，下载后可打开", (float)(_fileSize / 1000.f)];
            } else {
                title = [NSString stringWithFormat:@"文件大小为%dB，下载后可打开", (int)_fileSize];
            }
        } else {
            title = @"下载后可打开，是否下载？";
        }
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"暂不下载" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"确定下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self downloadFileIsExit:NO];
        }];
        [alertC addAction:cancelAction];
        [alertC addAction:doneAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)configDownloadViews {
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.progressLabel];
    _progressLabel.frame = CGRectMake(0, CGRectGetMaxY(_progressView.frame) + 25, CGRectGetWidth(self.view.bounds), 40);
}

- (void)configPreviewViews {
    self.navigationItem.rightBarButtonItem = _rightItem;
    _document = [UIDocumentInteractionController interactionControllerWithURL:_localFileUrl];
    _document.delegate = self;
    // 将QLPreviewControler  添加到本控制器上
    QLPreviewController * vc = [[QLPreviewController alloc] init];
    vc.dataSource = self;
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    [self.view addSubview:vc.view];
    vc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)downloadFileIsExit:(BOOL)isExit {
    NSString *file = _downloadPath;
    NSString *fileName = [[_Url.absoluteString componentsSeparatedByString:@"/"] lastObject];
    _localPathStr = [file stringByAppendingPathComponent:fileName];
    if (isExit) {
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:_localPathStr error:nil];
        long long localFileLength = [dict fileSize];
        if (localFileLength == _fileSize) {
            _localFileUrl = [NSURL fileURLWithPath:_localPathStr];
            [self configPreviewViews];
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:_localPathStr error:nil];
            [self afnDownloadFile];//:filePath fileName:fileName];
        }
    } else {
        [self afnDownloadFile];//:filePath fileName:fileName];
    }
}

- (void)afnDownloadFile {
    [self configDownloadViews];
    NSURLRequest * request = [NSURLRequest requestWithURL:_Url];
    _download = [self.session downloadTaskWithRequest:request];
    
    //执行Task
    [_download resume];
}

#pragma mark - action
- (void)handleClickRightItem {
    if (_warningView) {
        [_warningView hide];
        _warningView = nil;
        return;
    }
    UIImage * image = [UIImage imageNamed:@"ej_qlpreview_bubble"];
    UIEdgeInsets edgeInsert = UIEdgeInsetsZero;
    if (image) {
        edgeInsert = UIEdgeInsetsMake(12, 5, 10, 5);
    }
    _warningView = [[EJWarningCardView alloc] initWithTitleArray:@[@"用其他应用打开"] imageArray:nil AtPoint:CGPointMake(CGRectGetWidth(self.view.bounds) - 10, 5) AndSize:CGSizeMake(150, 50) EdgeInset:edgeInsert delegate:self];
    _warningView.titleFont = [UIFont systemFontOfSize:13];
    _warningView.textColor = UIColorHex(222222);
    _warningView.separatorInset = UIEdgeInsetsZero;
    _warningView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _warningView.separatorColor = UIColorHex(F0F0F0);
    _warningView.selectionStyle = UITableViewCellSelectionStyleNone;
    _warningView.cellHeight = 37.5;
    _warningView.textAlignment = NSTextAlignmentCenter;
    _warningView.isShowBg = YES;
    _warningView.backgroundColor = [UIColorHex(000000) colorWithAlphaComponent:0.5];
    _warningView.showFrom = WarningCardShowFromRightTop;
    
    if (image) {
        _warningView.backgroundImg = image;
    } else {
        _warningView.backgroundImg = [[UIImage imageWithColor:UIColorHex(ffffff) size:CGSizeMake(150, 50)] imageByRoundCornerRadius:3];
        _warningView.cellHeight = 50;
    }
    [_warningView showInView:self.view];
}

#pragma mark - EJWarningCardViewDelegate
- (void)ejwarningCardView:(EJWarningCardView *)warningView ClickButtonAtIndex:(NSInteger)index {
    BOOL canOpen = [self.document presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    if (canOpen == NO) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无应用可以打开" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.frame;
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return _localFileUrl;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    _localFileUrl = [NSURL fileURLWithPath:_localPathStr];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:_localFileUrl error:nil];
    [self configPreviewViews];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%lld", totalBytesWritten);
    NSLog(@"%f",1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    self.progressView.progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
//    self.progressLabel.text = [NSString stringWithFormat:@"%lld/%lld\n%.2f%%", totalBytesWritten, totalBytesExpectedToWrite, _progressView.progress * 100];
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", _progressView.progress * 100];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"下载失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

#pragma mark - getter or setter
- (NSURLSession *)session {
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.bounds) * 0.165, CGRectGetMidY(self.view.bounds) - 2, 0.67 * CGRectGetWidth(self.view.bounds), 4)];
        _progressView.trackTintColor = UIColorHex(E3E3E3);
        if (_progressColor) {
            _progressView.progressTintColor = _progressColor;
        } else if ([EJQLPreviewConfig sharedQLPreview].progressColor) {
            _progressView.progressTintColor = [EJQLPreviewConfig sharedQLPreview].progressColor;
        } else {
            _progressView.progressTintColor = UIColorHex(62C0BB);
        }
        _progressView.progress = 0;
        _progressView.layer.cornerRadius = 2;
    }
    return _progressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = UIColorHex(666666);
        _progressLabel.font = [UIFont systemFontOfSize:13];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.numberOfLines = 2;
    }
    return _progressLabel;
}

@end
