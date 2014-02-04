//
//  TTImageProcessor.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TTImageProcessor : NSObject

//处理单张图片/视频
-(void) process:(ALAsset*)asset;

-(NSInteger) processGroup:(ALAssetsGroup*)group;

-(void) processAllLibrary;

-(void) cleanDatabase;

@end
