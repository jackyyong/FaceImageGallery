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

// 数据转换方法
// 把OpenCV的Mat转换成iOS的NSData
+ (NSData *)NSDataFromCVMat:(cv::Mat&)cvMat;
// 把NSData转换成Mat
+ (cv::Mat)CVMatFromNSData:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height;
+ (cv::Mat)CVMatStandardizedFromNSData:(NSData*)imageData;

// 把OpenCV的Rect转换成iOS CGRect
+ (CGRect)CGRectFromCVRect:(cv::Rect)face;

// 把Mat转换成UIImage, 该方法支持灰度图像和彩色图像
+ (UIImage *)UIImageFromCVMat:(cv::Mat)image;
// 把灰度UIImage转换成Mat
+ (cv::Mat)CVMatGrayFromUIImage:(UIImage *)image;
// 把彩色UIImage转换成Mat
+ (cv::Mat)CVMatFromUIImage:(UIImage *)image;

// 讲UIImage转换成Mat, 转换成outputSpace指定的颜色空间
+ (cv::Mat)CVMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace;

// 将face标准化, 入口image为灰度图片
+ (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image;
// 将face标准化, 入口image为彩色
+ (cv::Mat)pullStandardizedFaceGray:(cv::Rect)face fromImage:(cv::Mat&)image;

@end
