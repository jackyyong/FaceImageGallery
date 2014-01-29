//
//  FIGCameraFinderViewController.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>
#import "FIGFaceDetector.h"
#import "FIGCustomFaceRecognizer.h"


//CvVideoCameraDelegate

@interface FIGCameraFinderViewController : UIViewController<CvPhotoCameraDelegate>
@property (nonatomic, strong) FIGFaceDetector *faceDetector;
@property (nonatomic, strong) FIGCustomFaceRecognizer *faceRecognizer;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *instructionLabel;
@property (nonatomic, strong) IBOutlet UILabel *confidenceLabel;

//CvVideoCamera
@property (nonatomic, strong) CvPhotoCamera* videoCamera;
@property (nonatomic, strong) CALayer *featureLayer;
@property (nonatomic) NSInteger frameNum;
@property (nonatomic) BOOL modelAvailable;
@end
