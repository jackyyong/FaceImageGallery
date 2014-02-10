//
//  FIGCenterViewController.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "FIGFaceDetector.h"

@interface TTRootCenterViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) FIGFaceDetector *faceDetector;

@property (assign, nonatomic) UIProgressView *processBar;

@property (assign, nonatomic) UILabel *processLabel;


@end
