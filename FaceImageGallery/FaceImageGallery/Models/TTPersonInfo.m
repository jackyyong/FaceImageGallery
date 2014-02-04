//
//  TTPersonInfo.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTPersonInfo.h"

@implementation TTPersonInfo


-(NSMutableArray *) photos {
    if (!_photos) {
        _photos  = [[NSMutableArray alloc]init];
    }
    return _photos;
}

-(NSMutableArray *) faces {
    if (!_faces) {
        _faces  = [[NSMutableArray alloc]init];
    }
    return _faces;
}

-(NSString *) name {
    if (!_name) {
        _name  = @"未标记";
    }
    return _name;
}

@end
