//
//  EJCameraShotVC.m
//  TeachingAssistantDemo
//
//  Created by Lius on 2017/7/14.
//  Copyright © 2017年 Lius. All rights reserved.
//

#import "EJCameraShotVC.h"
#import <CoreMotion/CoreMotion.h>
#import <EJTools/EJTools.h>
#import <LSToolsKit/LSToolsKit.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "EJPhotoSelectDefine.h"
#import "EJPhotoBrowser.h"
#import "UIViewController+LSAuthorization.h"

#import "NSString+EJShot.h"

@interface EJCameraShotVC ()<EJCameraShotDelegate, AVCaptureFileOutputRecordingDelegate, EJPhotoBrowserDelegate> {
    NSUInteger _shotCount;
}

@property (nonatomic, weak) id <EJCameraShotVCDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval shotTime;

@property (nonatomic, strong) EJCameraShotView *shotView;

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设置之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (nonatomic, strong) AVCaptureConnection * captureCon;


//照片输出流
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, copy) NSString *localFilePath;

@property (nonatomic, strong) NSURL *outPutURL;

@property (nonatomic, strong) NSMutableArray * assetIds;

@property (nonatomic, strong) EJProgressHUD *hud;

@property (nonatomic, strong) CMMotionManager* manager;
@property (nonatomic, strong) NSOperationQueue *queque;

@property (nonatomic, assign) AVCaptureVideoOrientation suggestOrientation;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;

@property (nonatomic, strong) NSMutableArray * browserSource;

@property (nonatomic, strong) UILabel * orientationLabel;

@property (nonatomic, weak) NSTimer * freeSizeTimer;

@end

@implementation EJCameraShotVC

#pragma mark - life cycle
- (instancetype)initWithShotTime:(NSTimeInterval)shotTime delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(AVCaptureVideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _shotTime = shotTime;
        _shotType = EJ_ShotType_Both;
        _maxCount = maxCount;
        _suggestOrientation = suggestOrientation;
        _shotCount = 0;
        
        _forcedCrop = NO;
        _cropScale = 0;
    }
    return self;
}

- (instancetype)initWithShotTime:(NSTimeInterval)shotTime shotType:(EJ_ShotType)shotType delegate:(id<EJCameraShotVCDelegate>)delegate suggestOrientation:(AVCaptureVideoOrientation)suggestOrientation /*allowPreview:(BOOL)allowPreview*/ maxCount:(NSUInteger)maxCount {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _shotTime = shotTime;
        _shotType = shotType;
//        _allowPreview = allowPreview;
        _maxCount = maxCount;
        _suggestOrientation = suggestOrientation;
        _shotCount = 0;
        
        _forcedCrop = NO;
        _cropScale = 0;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"orientation"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self initCamera];
    _shotView = [[EJCameraShotView alloc] initWithFrame:self.view.bounds shotTime:_shotTime shotType:self.shotType];
    _shotView.delegate = self;
//    [_shotView showPreviewImage:NO];
    [self.view addSubview:_shotView];
    
    [_shotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.orientationLabel];
    if (_suggestOrientation == AVCaptureVideoOrientationPortraitUpsideDown || _suggestOrientation == AVCaptureVideoOrientationPortrait) {
        _orientationLabel.text = @"建议竖屏拍摄";
    } else {
        _orientationLabel.text = @"建议横屏拍摄";
    }
    
    //kvo
    [self addObserver:self forKeyPath:@"orientation" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBg) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    _queque = [[NSOperationQueue alloc] init];
}

- (void)startMinitorOrientation {
    if (_manager == nil) {
        _manager = [[CMMotionManager alloc] init];
    }
    _manager.deviceMotionUpdateInterval = 1;
    if (_manager.deviceMotionAvailable == YES) {
        @weakify(self);
        [_manager startDeviceMotionUpdatesToQueue:_queque withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [weak_self handleDeviceMotion:motion];
        }];
    } else {
        _manager = nil;
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion {
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            self.orientation = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0){
            self.orientation =  AVCaptureVideoOrientationLandscapeRight;
        } else {
            self.orientation =  AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (_captureSession.isRunning == NO) {
        [_captureSession startRunning];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self judgeAppPhotoLibraryUsageAuth:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusRestricted: {
                NSLog(@"访问限制.");
            }
                break;
            case PHAuthorizationStatusDenied: {
                NSLog(@"访问被拒.");
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startMinitorOrientation];
                });
            }
                break;
            case PHAuthorizationStatusNotDetermined: {
                NSLog(@"未决定.");
            }
                break;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    if (self.manager.isDeviceMotionActive) {
        [self.manager stopAccelerometerUpdates];
        _manager = nil;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_localFilePath error:nil];
    }
//    if (_player) {
//        [_player pause];
//        _player = nil;
//    }
//    if (_playerLayer) {
//        [_playerLayer removeFromSuperlayer];
//        _playerLayer = nil;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCamera {
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {//设置分辨率
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }

    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }


    //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];


    NSError *error=nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }

    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        [captureConnection setEnabled:NO];
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }

    //将设备输出添加到会话中
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    [self.stillImageOutput setOutputSettings:outputSettings];
    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }


    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
        
    CGFloat height = kScreenWidth / 3.f * 4.f;
    CGFloat bottomSpace = 96 + kToolsBottomSafeHeight;
    CGFloat top = kScreenHeight - bottomSpace - height;
    if (top < 0) {
        top = 0;
    }
    CGRect frame = CGRectMake(0, top, kScreenWidth, height);
    if (top > (kScreenHeight - CGRectGetMaxY(frame))) {
        frame.origin.y = (kScreenHeight - CGRectGetHeight(frame)) / 2.f;
    }
    _captureVideoPreviewLayer.frame = frame;
    
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    [layer addSublayer:_captureVideoPreviewLayer];
}

- (void)setupCameraPreset:(AVCaptureSessionPreset)preset {
    if ([_captureSession canSetSessionPreset:preset]) {//设置分辨率
        _captureSession.sessionPreset = preset;
    } else {
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    if (preset == AVCaptureSessionPreset640x480) {
        
        CGFloat height = kScreenWidth / 3.f * 4.f;
        CGFloat bottomSpace = 96 + kToolsBottomSafeHeight;
        CGFloat top = kScreenHeight - bottomSpace - height;
        if (top < 0) {
            top = 0;
        }
        _captureVideoPreviewLayer.frame = CGRectMake(0, top, kScreenWidth, height);
    } else {
        _captureVideoPreviewLayer.frame = layer.bounds;
    }
}

- (void)handleChangeDevice {
    NSArray *inputs = self.captureSession.inputs;
    for (AVCaptureDeviceInput *input in inputs) {
        AVCaptureDevice *device = input.device;
        if ([device hasMediaType:AVMediaTypeVideo]) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;

            if (position == AVCaptureDevicePositionFront)
                newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];

            // beginConfiguration ensures that pending changes are not applied immediately
            [self.captureSession beginConfiguration];

            [self.captureSession removeInput:input];
            [self.captureSession addInput:newInput];

            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.captureSession commitConfiguration];
            break;
        }
    }
}

- (void)handleTakePhoto {

    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];

    if (!videoConnection) {
        return;
    }

    @weakify(self);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        @strongify(self);
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        if (imageData == nil) {
            return;
        }
        UIImage *image = [self flipImage:[UIImage imageWithData:imageData]];
        UIImage *resultImg = [image fixOrientation];
        [[LSSaveToAlbum mainSave] saveImage:resultImg successBlock:^(NSString *assetLocalId) {
            if ([assetLocalId length] > 0) {
                [self.assetIds addObject:assetLocalId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.maxCount == 1) {
//                        [self ls_teachingShotViewDidClickToClose];
                        [self ej_cameraShotViewDidClickPreviews];
                    } else {
                        _shotView.img = resultImg;
                        _shotView.previewCount = self.assetIds.count;
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [EJProgressHUD showAlert:@"保存到系统相册失败" forView:self.view];
                });
            }
        }];
    }];
}

- (void)recordAction {

    if ([self.captureMovieFileOutput isRecording]) {
        [self startMinitorOrientation];
        [self.captureMovieFileOutput stopRecording];
        return;
    }
    
    if (self.manager.isDeviceMotionActive) {
        [self.manager stopDeviceMotionUpdates];
        _manager = nil;
    }
    
    _uuid = [[NSUUID UUID] UUIDString];
    _fileName = [NSString stringWithFormat:@"%@.mov",_uuid];
    _localFilePath = [NSString stringWithFormat:@"%@/%@" , [NSString ej_shotDicPath], _fileName];
    //转为视频保存的url
    NSURL *url = [NSURL fileURLWithPath:_localFilePath];
    
    AVCaptureConnection * videoConnection = nil;
    for ( AVCaptureConnection *connection in [self.captureMovieFileOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts] ) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
    }
    
    if ([videoConnection isVideoOrientationSupported]) {
        if (_orientation == AVCaptureVideoOrientationLandscapeLeft) {
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        } else if (_orientation == AVCaptureVideoOrientationLandscapeRight) {
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        } else {
            [videoConnection setVideoOrientation:_orientation];
        }
    }
    [self.captureMovieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
    if (_freeSizeTimer) {
        [_freeSizeTimer invalidate];
        _freeSizeTimer = nil;
    }
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(handleJudgeSystemFreeSize:) userInfo:nil repeats:YES];
    _freeSizeTimer = timer;
}

- (void)stopRecord {
    if (_freeSizeTimer) {
        [_freeSizeTimer invalidate];
        _freeSizeTimer = nil;
    }
    if ([self.captureMovieFileOutput isRecording]) {
        [self startMinitorOrientation];
        [self.captureMovieFileOutput stopRecording];
        return;
    }
}

#pragma mark - action
- (void)handleBecomeActive {
    if (_captureSession.isRunning == NO) {
        [_captureSession startRunning];
    }
}

- (void)handleWillResignActive {
    if ([self.captureMovieFileOutput isRecording]) {
        [self startMinitorOrientation];
        [self.captureMovieFileOutput stopRecording];
        [self.shotView stopRecordVideo];
    }
    if (_captureSession.isRunning) {
        [_captureSession stopRunning];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"orientation"]) {
        NSNumber * oldValue = change[@"old"];
        NSNumber * currValue = change[@"new"];
        if ([oldValue integerValue] != [currValue integerValue]) {
            [self.shotView configOrientation:_orientation];
            [self showAlertOrientationLabel:_orientation];
        }
    }
}

- (void)showAlertOrientationLabel:(AVCaptureVideoOrientation)orientation {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_orientationLabel.superview) {
            return ;
        }
        if (_suggestOrientation == orientation || (_suggestOrientation <= 2 && orientation <= 2) || (_suggestOrientation > 2 && orientation > 2)) {
            _orientationLabel.hidden = YES;
            return;
        }
        CGAffineTransform transform = CGAffineTransformIdentity;
        _orientationLabel.hidden = NO;
        switch (orientation) {
            case AVCaptureVideoOrientationPortrait: {
                _orientationLabel.layer.position = CGPointZero;
                _orientationLabel.frame = CGRectMake((kScreenWidth - 190) / 2.f, kToolsStatusHeight, 190, 40);
                _orientationLabel.transform = CGAffineTransformIdentity;
            }
                break;
            case AVCaptureVideoOrientationLandscapeLeft: {
                _orientationLabel.layer.position = CGPointMake(kScreenWidth/ 2.f, kScreenHeight / 2.f);
                _orientationLabel.transform = CGAffineTransformIdentity;
                _orientationLabel.frame = CGRectMake((kScreenWidth - 190) / 2.f, 0, 190, 40);
                _orientationLabel.transform = CGAffineTransformRotate(transform, M_PI_2);
                _orientationLabel.left = kScreenWidth - 40;
                _orientationLabel.centerY = kScreenHeight / 2.f;
            }
                break;
            case AVCaptureVideoOrientationLandscapeRight: {
                _orientationLabel.layer.position = CGPointMake(kScreenWidth/ 2.f, kScreenHeight / 2.f);
                _orientationLabel.transform = CGAffineTransformIdentity;
                _orientationLabel.frame = CGRectMake((kScreenWidth - 190) / 2.f, 0, 190, 40);
                _orientationLabel.transform = CGAffineTransformRotate(transform, -M_PI_2);
                _orientationLabel.left = 0;
                _orientationLabel.centerY = kScreenHeight / 2.f;
            }
                break;
            case AVCaptureVideoOrientationPortraitUpsideDown: {
                _orientationLabel.layer.position = CGPointZero;
                _orientationLabel.frame = CGRectMake((kScreenWidth - 190) / 2.f, kScreenHeight - kToolsBottomSafeHeight - 100 - 40, 190, 40);
                _orientationLabel.transform = CGAffineTransformRotate(transform, M_PI);
            }
                break;
            default:
                break;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _orientationLabel.hidden = YES;
            [_orientationLabel removeFromSuperview];
        });
    });
}

- (void)handleJudgeSystemFreeSize:(NSTimer *)timer {
    BOOL isEnough = [UIDevice isEnoughFreeSizePer:0.01];
    if (!isEnough) {
        [self stopRecord];
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"停止拍摄" message:@"手机存储空间不足，请先清理空间后再次尝试！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"outputFileURL:%@",outputFileURL);
    NSString *outputURl = [NSString stringWithFormat:@"%@", outputFileURL];
    NSLog(@"error:%@",error);
    if (outputURl.length > 0) {
        //转为视频保存的url
        _outPutURL = [NSURL fileURLWithPath:_localFilePath];
        UIImage * coverImage = [UIImage thumbnailImageForVideo:_outPutURL atTime:0.1];

        _hud = [EJProgressHUD ej_showHUDAddToView:self.view animated:YES];
        [[LSSaveToAlbum mainSave] saveVideoWithUrl:_outPutURL successBlock:^(NSString *assetLocalId) {
            if ([assetLocalId length] > 0) {
                [self.assetIds addObject:assetLocalId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_hud hideAnimated:YES];
                    if (self.maxCount == 1) {
                        [self ej_cameraShotViewDidClickToClose];
                    } else {
                        self.shotView.img = coverImage;
                        self.shotView.previewCount = self.assetIds.count;
                        if ([[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
                            NSError * fileError = nil;
                            [[NSFileManager defaultManager] removeItemAtPath:_localFilePath error:&fileError];
                            if (fileError) {
                                NSLog(@"%@", fileError);
                            }
                        }
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [EJProgressHUD showAlert:@"保存到系统相册失败" forView:self.view];
                });
            }
        }];
    } else {
        [EJProgressHUD showConfirmAlert:@"保存失败,请重新录制!"];
    }

}

#pragma mark - EJCameraShotDelegate

- (void)ej_cameraShotViewDidClickToClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ej_cameraShotViewDidClickDone {
    if ([_localFilePath length] > 0 && [[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_localFilePath error:nil];
    }
    if ([self.delegate respondsToSelector:@selector(ej_shotVCDidShot:)]) {
        [self.delegate ej_shotVCDidShot:self.assetIds];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ej_cameraShotViewDidClickToChangeDevice {
    //切换摄像头
    [self handleChangeDevice];
}

- (void)ej_cameraShotViewDidClickCameraButtonToTakePhoto {
    if (_shotCount >= _maxCount) {
        return;
    }
    _shotCount += 1;
    //拍照
    [self handleTakePhoto];
}

- (void)showMaxCountHud {
    _hud = [[EJProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    if (_shotType == EJ_ShotType_Photo) {
        _hud.label.text = [NSString stringWithFormat:@"最多只能拍摄%d张照片", (int)_maxCount];
    } else if (_shotType == EJ_ShotType_Video) {
        _hud.label.text = [NSString stringWithFormat:@"最多只能拍摄%d个视频", (int)_maxCount];
    } else {
        _hud.label.text = [NSString stringWithFormat:@"最多只能拍摄%d个照片或视频", (int)_maxCount];
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (_orientation) {
        case AVCaptureVideoOrientationPortrait: {
            _hud.transform = CGAffineTransformIdentity;
        }
            break;
        case AVCaptureVideoOrientationLandscapeLeft: {
            _hud.transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
        case AVCaptureVideoOrientationLandscapeRight: {
            _hud.transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown: {
            _hud.transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
        default:
            break;
    }
    
    _hud.mode = MBProgressHUDModeText;
    [_hud showAnimated:YES];
    [_hud hideAnimated:YES afterDelay:1.5f];
    [_hud removeFromSuperViewOnHide];
}

- (void)ej_cameraShotViewDidClickToRecordVideoWithStart:(BOOL)isStart {
    if (isStart) {
        _shotCount += 1;
        [self recordAction];
        
    } else {
        [self stopRecord];
    }
}

- (void)ej_cameraShotViewDidClickToSend {
    if ([_localFilePath length] > 0 && [[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_localFilePath error:nil];
    }
    //发送文件
    if ([self.delegate respondsToSelector:@selector(ej_shotVCDidShot:)]) {
        [self.delegate ej_shotVCDidShot:self.assetIds];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)ej_cameraShotViewDidClickToRerecord {
    if ([self.assetIds count] > 0) {
        [self.assetIds removeLastObject];
    }
    if ([NSString stringWithFormat:@"%@",_outPutURL].length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:_outPutURL.absoluteString error:nil];
    }
}

- (BOOL)ej_cameraShotViewCanShot {
    if ([self.assetIds count] < _maxCount || _shotCount < _maxCount) {
        return YES;
    } else {
        [self showMaxCountHud];
        return NO;
    }
}

- (void)ej_cameraShotViewDidClickPreviews {
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    [self.browserSource removeAllObjects];
    PHFetchResult <PHAsset *>* result = [PHAsset fetchAssetsWithLocalIdentifiers:self.assetIds options:nil];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.browserSource addObject:[EJPhoto photoWithAsset:obj targetSize:imageTargetSize]];
    }];
    
    EJPhotoBrowser * brower = [[EJPhotoBrowser alloc] initWithDelegate:self];
    brower.showCropButton = YES;
    brower.showSelectButton = YES;
    [brower setCurrentPhotoIndex:0];
    brower.isPreview = YES;
    brower.forcedCrop = _forcedCrop;
    [self.navigationController pushViewController:brower animated:YES];
}

- (void)ej_cameraShotViewDidChangeToShotPhoto:(BOOL)isShotPhoto {
    if (isShotPhoto == YES) {
        // 拍照
        [self setupCameraPreset:AVCaptureSessionPreset640x480];
    } else {
        // 视频
        [self setupCameraPreset:AVCaptureSessionPreset1280x720];
    }
}

#pragma mark - EJPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(EJPhotoBrowser *)photoBrowser {
    return [self.browserSource count];
}

- (id<EJPhoto>)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.browserSource objectAtIndex:index];
}

- (BOOL)photoBrowser:(EJPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return YES;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    if (selected == NO) {
        [self.browserSource removeObjectAtIndex:index];
//        if (index == self.assetIds.count - 1) {
//            NSString * Id = [self.assetIds objectAtIndex:index];
//            PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[Id] options:nil].firstObject;
//            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                _shotView.img = result;
//            }];
//        }
        [self.assetIds removeObjectAtIndex:index];
        _shotCount --;
        if ([self.assetIds count] > 0) {
//            NSString * Id = [self.assetIds objectAtIndex:index];
            NSString * Id = [self.assetIds lastObject];
            PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[Id] options:nil].firstObject;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                _shotView.img = result;
            }];
            _shotView.previewCount = self.assetIds.count;
        } else {
            _shotView.img = nil;
            _shotView.previewCount = 0;
        }
        [photoBrowser reloadData];
    }
}

- (NSUInteger)photoBrowserMaxSelectePhotoCount:(EJPhotoBrowser *)photoBrowser {
    return _maxCount;
}

- (NSUInteger)photoBrowserSelectedPhotoCount:(EJPhotoBrowser *)photoBrowser {
    return [self.assetIds count];
}

- (CGFloat)photoBrowser:(EJPhotoBrowser *)photoBrowser crapScaleAtIndex:(NSUInteger)index {
    return _cropScale;
}

- (void)photoBrowser:(EJPhotoBrowser *)photoBrowser didCropPhotoAtIndex:(NSUInteger)index assetId:(NSString *)assetId {
    id item = [self.assetIds objectOrNilAtIndex:index];
    if (item == nil) {
        [photoBrowser reloadData];
        return;
    }
    PHAsset * asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil] firstObject];
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
    EJPhoto * currPhoto = [EJPhoto photoWithAsset:asset targetSize:imageTargetSize];
    [self.browserSource replaceObjectAtIndex:index withObject:currPhoto];
    [self.assetIds replaceObjectAtIndex:index withObject:assetId];
    if (index == 0) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            _shotView.img = result;
        }];
    }
    [photoBrowser reloadData];
}

- (void)photoBrowserDidFinish:(EJPhotoBrowser *)photoBrowser {
    [self ej_cameraShotViewDidClickDone];
}

- (void)photoBrowserDidCancel:(EJPhotoBrowser *)photoBrowser {
    if (_maxCount == 1) {
        [self ej_cameraShotViewDidClickToClose];
    } else {
        
    }
}

#pragma mark - private
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {

    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

- (UIImage*)flipImage:(UIImage*)image {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (_orientation == AVCaptureVideoOrientationPortrait) {
        transform = CGAffineTransformTranslate(transform, 0 ,image.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        CGContextRef ctx =CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                                CGImageGetBitsPerComponent(image.CGImage), 0,
                                                CGImageGetColorSpace(image.CGImage),
                                                CGImageGetBitmapInfo(image.CGImage));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx,CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }
    else if (_orientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        CGContextRef ctx =CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                                CGImageGetBitsPerComponent(image.CGImage),0,
                                                CGImageGetColorSpace(image.CGImage),
                                                CGImageGetBitmapInfo(image.CGImage));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }
    else if (_orientation == AVCaptureVideoOrientationLandscapeLeft) {
        CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                                 CGImageGetBitsPerComponent(image.CGImage), 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }
    else if (_orientation == AVCaptureVideoOrientationLandscapeRight) {
        transform = CGAffineTransformTranslate(transform, image.size.height, image.size.width);
        transform = CGAffineTransformRotate(transform, M_PI);
        CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.height, image.size.width,
                                                 CGImageGetBitsPerComponent(image.CGImage), 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
    }
    return image;
}

#pragma mark - getter or setter
- (NSMutableArray *)assetIds {
    if (!_assetIds) {
        _assetIds = [NSMutableArray arrayWithCapacity:1];
    }
    return _assetIds;
}

- (NSMutableArray *)browserSource {
    if (!_browserSource) {
        _browserSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _browserSource;
}

- (UILabel *)orientationLabel {
    if (!_orientationLabel) {
        _orientationLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 190) / 2.f, kToolsStatusHeight, 190, 40)];
        _orientationLabel.backgroundColor = [UIColorHex(333333) colorWithAlphaComponent:0.4];
        _orientationLabel.font = [UIFont systemFontOfSize:13];
        _orientationLabel.textColor = UIColorHex(fefefe);
        _orientationLabel.textAlignment = NSTextAlignmentCenter;
        _orientationLabel.layer.cornerRadius = 5;
        _orientationLabel.layer.masksToBounds = YES;
        _orientationLabel.hidden = YES;
    }
    return _orientationLabel;
}

@end
