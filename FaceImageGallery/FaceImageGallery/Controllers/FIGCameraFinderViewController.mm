//
//  FIGCameraFinderViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGCameraFinderViewController.h"
#import "FIGOpenCVData.h"

#define CAPTURE_FPS 30
@interface FIGCameraFinderViewController ()

- (IBAction)switchCameraClicked:(id)sender;
- (IBAction)takeCameraClicked:(UIButton *)sender;
- (IBAction)retakeCameraClicked:(UIButton *)sender;

@end

@implementation FIGCameraFinderViewController


- (IBAction)switchCameraClicked:(id)sender {
    [self.videoCamera stop];
    
    if (self.videoCamera.defaultAVCaptureDevicePosition == AVCaptureDevicePositionFront) {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    } else {
        self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    }
    
    [self.videoCamera start];
}

- (IBAction)takeCameraClicked:(UIButton *)sender {
    [self.videoCamera takePicture];
}

- (IBAction)retakeCameraClicked:(UIButton *)sender {
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.faceDetector = [[FIGFaceDetector alloc] init];
    //self.faceRecognizer = [[FIGCustomFaceRecognizer alloc] initWithLBPHFaceRecognizer];
    //self.faceRecognizer = [[FIGCustomFaceRecognizer alloc] initWithFisherFaceRecognizer];
    self.faceRecognizer = [[FIGCustomFaceRecognizer alloc] initWithEigenFaceRecognizer];
    [self setupCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Re-train the model in case more pictures were added
    self.modelAvailable = [self.faceRecognizer trainModel];
    
    if (!self.modelAvailable) {
        self.instructionLabel.text = @"Add people in the database first";
    }
    
    [self.videoCamera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.videoCamera stop];
}

- (void)setupCamera
{
    self.videoCamera = [[CvPhotoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = CAPTURE_FPS;
    // self.videoCamera.grayscaleMode = NO;
}

- (void)photoCamera:(CvPhotoCamera*)photoCamera capturedImage:(UIImage *)image {
    
}


- (void)photoCameraCancel:(CvPhotoCamera*)photoCamera {
    
}

- (void)processImage:(cv::Mat&)image
{
    // Only process every CAPTURE_FPS'th frame (every 1s)
    if (self.frameNum == CAPTURE_FPS) {
        [self parseFaces:[self.faceDetector facesFromImage:image] forImage:image];
        self.frameNum = 0;
    }
    
    self.frameNum++;
}

- (void)parseFaces:(const std::vector<cv::Rect> &)faces forImage:(cv::Mat&)image
{
    // No faces found
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return;
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    // By default highlight the face in red, no match found
    CGColor *highlightColor = [[UIColor redColor] CGColor];
    NSString *message = @"No match found";
    NSString *confidence = @"";
    
    // Unless the database is empty, try a match
    if (self.modelAvailable) {
        NSDictionary *match = [self.faceRecognizer recognizeFace:face inImage:image];
        
        // Match found
        if ([match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
            message = [match objectForKey:@"personName"];
            highlightColor = [[UIColor greenColor] CGColor];
            
            NSNumberFormatter *confidenceFormatter = [[NSNumberFormatter alloc] init];
            [confidenceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            confidenceFormatter.maximumFractionDigits = 2;
            
            confidence = [NSString stringWithFormat:@"Confidence: %@",
                          [confidenceFormatter stringFromNumber:[match objectForKey:@"confidence"]]];
        }
    }
    
    // All changes to the UI have to happen on the main thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = message;
        self.confidenceLabel.text = confidence;
        [self highlightFace:[FIGOpenCVData faceToCGRect:face] withColor:highlightColor];
    });
}
/*
-(bool) detectAndDisplay:(cv::Mat&) frame
{
    BOOL bFaceFound = false;
    std::vector<cv::Rect> faces;
    cv::Mat frame_gray;
    
    cvtColor(frame, frame_gray, CV_BGRA2GRAY);
    
    equalizeHist(frame_gray, frame_gray);
    
    // face_cascade.detectMultiScale(frame_gray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, cv::Size(100, 100));

    faces = [self.faceDetector facesFromImage:frame_gray];
    
    for(unsigned int i = 0; i < faces.size(); ++i) {
        rectangle(frame, cv::Point(faces[i].x, faces[i].y),
                  cv::Point(faces[i].x + faces[i].width, faces[i].y + faces[i].height),
                  cv::Scalar(0,255,255));
        bFaceFound = true;
    }
    return bFaceFound;
}

//CvVideoCamera delegate
-(void)processImage:(cv::Mat&)image;
{
    if (self.frameNum != CAPTURE_FPS) {
        self.frameNum++;
        return;
    }
    
    self.frameNum = 0;
    
    cv::Mat tmpMat;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    BOOL isInLandScapeMode = NO;
    BOOL rotation = 1;
    
    //Rotate cv::Mat to the portrait orientation
    if(orientation == UIDeviceOrientationLandscapeRight)
    {
        isInLandScapeMode = YES;
        rotation = 1;
    }
    else if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        isInLandScapeMode = YES;
        rotation = 0;
    }
    else if(orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, rotation);
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, rotation);
        cvtColor(image, image, CV_BGR2BGRA);
        cvtColor(image, image, CV_BGR2RGB);
    }
    
    if(isInLandScapeMode)
    {
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, rotation);
        cvtColor(image, image, CV_BGR2BGRA);
        cvtColor(image, image, CV_BGR2RGB);
    }
    
    [self detectAndDisplay:image];
    
    if(isInLandScapeMode)
    {
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, !rotation);
        cvtColor(image, image, CV_BGR2RGB);
        
    }
    else if(orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, !rotation);
        cv::transpose(image, tmpMat);
        cv::flip(tmpMat, image, !rotation);
        cvtColor(image, image, CV_BGR2RGB);
    }
        
}*/

- (void)noFaceToDisplay
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.instructionLabel.text = @"No face in image";
        self.confidenceLabel.text = @"";
        self.featureLayer.hidden = YES;
    });
}

- (void)highlightFace:(CGRect)faceRect withColor:(CGColor *)color
{
    if (self.featureLayer == nil) {
        self.featureLayer = [[CALayer alloc] init];
        self.featureLayer.borderWidth = 4.0;
    }
    
    [self.imageView.layer addSublayer:self.featureLayer];
    
    self.featureLayer.hidden = NO;
    self.featureLayer.borderColor = color;
    self.featureLayer.frame = faceRect;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
