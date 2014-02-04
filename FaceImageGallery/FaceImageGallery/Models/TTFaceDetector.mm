//
//  TTFaceDetector.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-4.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//
#import "TTFaceDetector.h"


// CV_HAAR_FIND_BIGGEST_OBJECT - 只检测最大的物体
// CV_HAAR_DO_ROUGH_SEARCH - 只做初略检测
// CV_HAAR_DO_CANNY_PRUNING - 利用Canny边缘检测器来排除一些边缘很少或者很多的图像区域
// CV_HAAR_SCALE_IMAGE - 就是按比例正常检测
@implementation TTFaceDetector

- (id)init
{
    self = [super init];
    if (self) {
        NSString * faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2"
                                                                    ofType:@"xml"];
        //加载级联分类器
        if (!_faceCascade.load([faceCascadePath UTF8String])) {
            NSLog(@"Could not load face cascade: %@", faceCascadePath);
        }
    }
    
    return self;
}

- (std::vector<cv::Rect>)facesFromCVImage:(cv::Mat&)image
{
    std::vector<cv::Rect> faces;
    // 参数image为输入的灰度图像
    // 参数 faces 被检测物体的矩形框向量组
    // 第三个参数scaleFactor为每一个图像尺度中的尺度参数
    
    _faceCascade.detectMultiScale(image, faces, 1.1, 2, (CV_HAAR_SCALE_IMAGE), cv::Size(30, 30));

    return faces;
}

@end