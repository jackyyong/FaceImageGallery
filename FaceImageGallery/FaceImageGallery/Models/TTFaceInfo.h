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
    @property (nonatomic, assign) NSInteger id;
    
    // Person id
    @property (nonatomic, assign) NSInteger personId;
    
    // 面孔存在的图片Id
    @property (nonatomic, assign) NSInteger photoId;
    
    // 面孔图片数据
    @property (nonatomic, strong) NSData * image;

    // 此面孔所在的图片信息
    @property (nonatomic, strong) TTPhotoInfo * photoInfo;


@end
