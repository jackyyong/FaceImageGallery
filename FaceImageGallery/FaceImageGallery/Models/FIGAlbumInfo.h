//
//  FIGAlbumInfo.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-1.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FIGPhotoInfo.h"

@interface FIGAlbumInfo : NSObject

// 相册海报图片
@property (nonatomic, assign) CGImageRef posterImage;
// 相册名称
@property (nonatomic, assign) NSString * albumName;

// 相册相片数量
@property (nonatomic, assign) NSInteger numberOfPhotos;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) NSMutableArray *photos;

- (NSInteger) getPhotosCount;

- (void)readPhotos;

- (void)removeAllPhotos;


-(FIGPhotoInfo * )getPhotoInfoAtIndex:(NSInteger) index;



@end

