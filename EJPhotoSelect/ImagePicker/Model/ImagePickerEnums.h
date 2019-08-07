//
//  ImagePickerEnums.h
//  MonitorIOS
//
//  Created by LiuShuang on 2019/5/27.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#ifndef ImagePickerEnums_h
#define ImagePickerEnums_h

typedef enum : NSUInteger {
    E_SourceType_Image  = 0,
    E_SourceType_Video,
    E_SourceType_All,
} E_SourceType;

typedef enum : NSUInteger {
    LSSortOrderAscending,
    LSSortOrderDescending,
} LSSortOrder;

#endif /* ImagePickerEnums_h */
