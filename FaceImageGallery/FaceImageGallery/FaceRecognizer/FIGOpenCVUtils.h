//
//  FIGOpenCVUtils.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
@interface FIGOpenCVUtils : NSObject

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
+ (cv::Mat)cvMatWithImage:(UIImage *)image;

@end
