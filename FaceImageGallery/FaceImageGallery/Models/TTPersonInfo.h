//
//  TTPersonInfo.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPersonInfo : NSObject

    // 编号
   @property (nonatomic, assign) NSInteger id;
    
   // 名称
   @property (nonatomic, strong) NSString * name;
    
    // 是否从通讯录连接
   @property (nonatomic, assign) BOOL linkFromContact;
    
    // 显示的面孔id
   @property (nonatomic, assign) NSInteger showFaceId;
    
    // 关联的图片数量
   @property (nonatomic, assign) NSInteger relatedPhotosCount;
    
    // 关联的所有的图片, 类型是 TTPhotoInfo
   @property (nonatomic, strong) NSMutableArray * photos;
    
    // 关联的所有的Face, 类型是 TTFaceInfo
   @property (nonatomic, strong) NSMutableArray * faces;


@end
