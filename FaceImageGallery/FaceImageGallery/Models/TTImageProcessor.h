//
//  TTImageProcessor.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TTImageProcessorDelegate.h"

    // 图片处理器
@interface TTImageProcessor : NSObject

@property(nonatomic,assign)id<TTImageProcessorDelegate> delegate;

    // 处理整个图片库
    -(void) processAllLibrary;

    -(BOOL) isDatabaseCreated;

@end
