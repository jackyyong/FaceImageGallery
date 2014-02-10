//
//  TTPhotoInfo.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPhotoInfo : NSObject

    // 图片id
    @property (nonatomic, assign) NSUInteger id;
    
    // 拍摄时间
    @property (nonatomic, retain) NSString * takeTime;
    
    // 图片地址
    @property (nonatomic, retain) NSString * absoluteURL;
    
    // 图片宽度
    @property (nonatomic, assign) CGFloat width;
    
    // 图片高度
    @property (nonatomic, assign) CGFloat height;
    
    // 图片拍摄位置 - latitude-维度
    @property (nonatomic, assign) double latitude;
    
    // 图片拍摄位置 - longitude-经度
    @property (nonatomic, assign) double longitude;
    
    // 图片拍摄海拔高度
    @property (nonatomic, assign) double altitude;

    @property (nonatomic, assign) float scale;

    // 关联的所有的Face, 类型是 TTFaceInfo
    @property (nonatomic, strong) NSMutableArray * faces;

@end
