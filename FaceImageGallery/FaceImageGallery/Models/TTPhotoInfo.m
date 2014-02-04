//
//  TTPhotoInfo.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTPhotoInfo.h"

@implementation TTPhotoInfo

-(NSMutableArray *) faces {
    if (!_faces) {
        _faces  = [[NSMutableArray alloc]init];
    }
    return _faces;
}

@end
