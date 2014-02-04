//
//  TTOpenCVData.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface TTOpenCVData : NSObject

+ (NSData *)serializeCvMat:(cv::Mat&)cvMat;

+ (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height;

+ (CGRect)faceToCGRect:(cv::Rect)face;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)image;

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

@end
