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
            //haarcascade_frontalface_default
            //haarcascade_frontalface_alt
        NSString * faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default"
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
    std::vector<int> reject_levels;
    std::vector<double> level_weights;
    
    // 参数 faces 被检测物体的矩形框向量组
    // 第三个参数scaleFactor为每一个图像尺度中的尺度参数
    // 直方图均衡化
    cv::equalizeHist(image, image);
    
    _faceCascade.detectMultiScale(image, faces, 1.2, 4, 0, cv::Size(20, 20));
    
    return faces;
}

@end