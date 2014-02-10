//
//  TTImageProcessorDelegate.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-9.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol TTImageProcessorDelegate;

@protocol TTImageProcessorDelegate <NSObject>
@required
    // Group
-(void) whenNewGroupFound:(ALAssetsGroup*)group;

    // Asset
-(void) whenNewAssetFound:(ALAsset*)asset;

    // Asset
-(void) whenNewAssetProcessEnd:(ALAsset*)asset;

    // Person
-(void) whenNewPersonFound:(NSInteger)personId;

    // Face
-(void) whenNewFaceFound:(NSInteger)faceId;



@end