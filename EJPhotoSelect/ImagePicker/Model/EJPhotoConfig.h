//
//  EJPhotoConfig.h
//  AFNetworking
//
//  Created by 刘爽 on 2019/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EJPhotoConfig : NSObject

@property (nonatomic, strong) UIColor * tintColor;

@property (nonatomic, strong) UIColor * barTintColor;

@property (nonatomic, strong) UIColor * majorTitleColor;


+ (instancetype)sharedPhotoConfig;

@end

NS_ASSUME_NONNULL_END
