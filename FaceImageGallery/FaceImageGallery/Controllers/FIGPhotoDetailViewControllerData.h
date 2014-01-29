//
//  FIGPhotoDetailViewControllerData.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FIGPhotoDetailViewControllerData : NSObject

+ (FIGPhotoDetailViewControllerData *)sharedInstance;

@property (nonatomic, strong) NSArray *photoAssets; // array of ALAsset objects

- (NSUInteger)photoCount;
- (UIImage *)photoAtIndex:(NSUInteger)index;

@end