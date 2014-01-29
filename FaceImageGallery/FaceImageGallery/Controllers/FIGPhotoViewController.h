//
//  FIGPhotoDetailViewController.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIGPhotoViewController : UIViewController

@property (nonatomic, strong) NSArray *photos;  // array of ALAsset objects

@property NSUInteger pageIndex;

+ (FIGPhotoViewController *)photoViewControllerForPageIndex:(NSUInteger)pageIndex;

@end
