//
//  ImageScrollView.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FIGImageScrollView : UIScrollView
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic) NSUInteger index;

+ (NSUInteger)imageCount;
@end
