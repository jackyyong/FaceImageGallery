//
//  FIGPhotoDetailViewControllerData.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGPhotoDetailViewControllerData.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FIGPhotoDetailViewControllerData

+ (FIGPhotoDetailViewControllerData *)sharedInstance
{
    static dispatch_once_t onceToken;
    static FIGPhotoDetailViewControllerData *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[FIGPhotoDetailViewControllerData alloc] init];
    });
    
    return sSharedInstance;
}

- (NSUInteger)photoCount
{
    return self.photoAssets.count;
}

- (UIImage *)photoAtIndex:(NSUInteger)index
{
    ALAsset *photoAsset = self.photoAssets[index];
    
    ALAssetRepresentation *assetRepresentation = [photoAsset defaultRepresentation];
    
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:ALAssetOrientationUp];
    return fullScreenImage;
}

@end

