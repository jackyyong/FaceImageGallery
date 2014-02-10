//
//  TTOpenCVData.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTOpenCVData.h"
#import "TTCst.h"

@implementation TTOpenCVData


+ (NSData *)NSDataFromCVMat:(cv::Mat&)cvMat
{
    return [[NSData alloc] initWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
}

+ (cv::Mat)CVMatFromNSData:(NSData *)data width:(NSNumber *)width height:(NSNumber *)height
{
    cv::Mat output = cv::Mat((int)[width integerValue], (int)[height integerValue], CV_8UC1);
    output.data = (unsigned char*)data.bytes;
    return output;
}

+ (cv::Mat)CVMatStandardizedFromNSData:(NSData*)imageData
{
   return [TTOpenCVData CVMatFromNSData:imageData
                            width:[NSNumber numberWithInt:TRAIN_FACE_WIDTH]
                           height:[NSNumber numberWithInt:TRAIN_FACE_HEIGHT]];
}

+ (CGRect)CGRectFromCVRect:(cv::Rect)face
{
    CGRect faceRect;
    faceRect.origin.x = face.x;
    faceRect.origin.y = face.y;
    faceRect.size.width = face.width;
    faceRect.size.height = face.height;
    
    return faceRect;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)image
{
    NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(
                                        image.cols,                                 //width
                                        image.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * image.elemSize(),                       //bits per pixel
                                        image.step.p[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Create UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    CGDataProviderRelease(provider);
    
    return finalImage;
}

+ (cv::Mat)CVMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    
    CGContextRelease(contextRef);
    
    return cvMat;
    
    //return [TTOpenCVData cvMatFromUIImage:image usingColorSpace:CV_RGB2GRAY];
}

+ (cv::Mat)CVMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

+ (cv::Mat)CVMatFromUIImage:(UIImage *)image usingColorSpace:(int)outputSpace
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4);
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast|kCGBitmapByteOrderDefault // Bitmap info flags
                                                    );
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    cv::Mat finalOutput;
    cvtColor(cvMat, finalOutput, outputSpace);
    
    return finalOutput;
}

+ (cv::Mat)pullStandardizedFaceGray:(cv::Rect)face fromImage:(cv::Mat&)image
{
    cv::Mat onlyTheFace;
    
    cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    
    cv::resize(onlyTheFace, onlyTheFace, cv::Size(TRAIN_FACE_WIDTH, TRAIN_FACE_HEIGHT), 0, 0);
    
    return onlyTheFace;
}


+ (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
    cv::Mat onlyTheFace;
    
    cv::resize(image(face), onlyTheFace, cv::Size(TRAIN_FACE_WIDTH, TRAIN_FACE_HEIGHT), 0, 0);
    
    return onlyTheFace;
}

@end
