//
//  EJResponseModel.h
//  IOSParents
//
//  Created by Lius on 2018/6/4.
//  Copyright © 2018年 ejiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EJResponseModel : NSObject

@property (nonatomic, assign) NSInteger ResponseStatus;

@property (nonatomic, copy) NSString * ErrorMessage;

@property (nonatomic, weak) id Data;

@end
