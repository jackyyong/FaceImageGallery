//
//  TTFaceDetector.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-4.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>

@interface TTFaceDetector : NSObject {
    cv::CascadeClassifier _faceCascade;
}

- (std::vector<cv::Rect>)facesFromCVImage:(cv::Mat&)image;

@end