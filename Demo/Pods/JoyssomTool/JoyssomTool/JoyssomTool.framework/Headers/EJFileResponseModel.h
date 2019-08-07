//
//  EJFileResponseModel.h
//  IOSParents
//
//  Created by Lius on 2018/2/8.
//  Copyright © 2018年 ejiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EJFileResponseModel : NSObject

@property (nonatomic, assign) BOOL IsSuccess;

@property (nonatomic, assign) NSInteger  StartOffset;

@property (nonatomic, copy) NSString * Msg;

@property (nonatomic, copy) NSString * ThumbnailPath;

@end
