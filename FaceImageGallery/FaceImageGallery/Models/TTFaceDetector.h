//
//  TTFaceDetector.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-4.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

// 人脸探测器
@interface TTFaceDetector : NSObject {
    
    // 人脸级联分类器
    // Type of cascade classifier                                      XML filename
    // Face detector (default)                                         haarcascade_frontalface_default.xml
    // Face detector (fast Haar)                                       haarcascade_frontalface_alt2.xml
    // Face detector (fast LBP)                                        lbpcascade_frontalface.xml
    // Profile (side-looking) face detector                            haarcascade_profileface.xml
    // Eye detector (separate for left and right)                      haarcascade_lefteye_2splits.xml
    // Mouth detector                                                  haarcascade_mcs_mouth.xml
    // Nose detector                                                   haarcascade_mcs_nose.xml
    // Whole person detector                                           haarcascade_fullbody.xml
    
    
    // 人眼
    // 可以识别睁开和闭上的眼睛的眼睛探测器                                  haarcascade_mcs_lefteye.xml haarcascade_mcs_righteye.xml
    // 只能识别睁开的眼睛的探测器                                          haarcascade_eye.xml
    // 可以探测戴着眼镜                                                   haarcascade_eye_tree_eyeglasses.xml
    //haarcascade_frontalface_alt 正面人脸探测
    cv::CascadeClassifier _faceCascade;
    
    
}

// 参数image为输入的灰度图像
// 参数image为输入图像矩阵[Mat为OpenCV 基本图像容器]
// 返回值: faces 被检测物体的矩形框向量组
- (std::vector<cv::Rect>)facesFromCVImage:(cv::Mat&)image;

@end