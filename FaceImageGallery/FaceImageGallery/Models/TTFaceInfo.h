//
//  TTFaceInfo.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTPhotoInfo.h"

@interface TTFaceInfo : NSObject

    // 面孔id
    @property (nonatomic, assign) NSUInteger id;
    
    // Person id
    @property (nonatomic, assign) NSUInteger personId;
    
    // 面孔存在的图片Id
    @property (nonatomic, assign) NSUInteger photoId;

    // 面孔在图片中的矩形坐标x
    @property (nonatomic, assign) NSUInteger rectX;

    // 面孔在图片中的矩形坐标y
    @property (nonatomic, assign) NSUInteger rectY;

    // 面孔在图片中的矩形宽度
    @property (nonatomic, assign) NSUInteger rectWidth;

    // 面孔在图片中的矩形高度
    @property (nonatomic, assign) NSUInteger rectHeight;
    
    // 面孔图片数据
    @property (nonatomic, retain) NSString * image;

    @property (nonatomic, strong) NSData * trainData;

    // 识别信心指数
    @property (nonatomic, assign) double confidence;

    // 此面孔所在的图片信息
    @property (nonatomic, strong) TTPhotoInfo * photoInfo;


@end
