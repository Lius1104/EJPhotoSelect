//
//  EJAlbumPickerVC.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

//#import "EJViewController.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ImagePickerEnums.h"

//NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickAlbumBlock)(PHAssetCollection * collection);


@interface EJAlbumPickerVC : UIViewController

- (instancetype)initWithSourceType:(E_SourceType)sourceType clickAlbumBlock:(ClickAlbumBlock)block;

@end

//NS_ASSUME_NONNULL_END
