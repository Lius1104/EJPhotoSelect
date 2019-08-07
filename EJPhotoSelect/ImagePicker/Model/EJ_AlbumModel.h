//
//  EJ_AlbumModel.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface EJ_AlbumModel : NSObject

@property (nonatomic, strong) PHAssetCollection * assetCollection;

@property (nonatomic, strong) UIImage * coverImg;

@property (nonatomic, assign) NSInteger sourceCount;

@end
