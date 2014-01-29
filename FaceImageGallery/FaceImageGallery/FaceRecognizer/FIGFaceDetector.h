//
//  FaceDetector.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface FIGFaceDetector : NSObject
{
    //OpenCV支持的目标检测的方法是利用样本的Haar特征进行的分类器训练，得到的级联boosted分类器（Cascade Classification）
    cv::CascadeClassifier _faceCascade;
}

- (std::vector<cv::Rect>)facesFromImage:(cv::Mat&)image;

@end
