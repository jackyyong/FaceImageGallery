//
//  FIGOpenCVData.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FIGOpenCVData : NSObject

+ (NSData *)serializeCvMat:(cv::Mat&)cvMat;
+ (cv::Mat)dataToMat:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height;
+ (CGRect)faceToCGRect:(cv::Rect)face;
+ (UIImage *)UIImageFromMat:(cv::Mat)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace;
@end
