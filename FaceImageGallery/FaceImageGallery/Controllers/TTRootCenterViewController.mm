//
//  FIGCenterViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTRootCenterViewController.h"
#import <opencv2/highgui/cap_ios.h>
#import "FIGOpenCVUtils.h"
#import "FIGOpenCVData.h"
#import "TTImageProcessor.h"

@interface TTRootCenterViewController ()

@property (assign, nonatomic) UIImageView *previewView;
@property (assign, nonatomic) UIImageView *faceView;
@property (assign, nonatomic) UILabel *messageLabel;
@property (nonatomic, strong) TTImageProcessor *processor;

- (IBAction)cameraButtonAction:(UIButton *)sender;
- (IBAction)selectButtonAction:(UIButton *)sender;

@end


@implementation TTRootCenterViewController

-(TTImageProcessor*) processor {
    if(!_processor) {
        _processor = [[TTImageProcessor alloc] init];
    }
    
    return _processor;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    // Custom initialization
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.faceDetector = [[FIGFaceDetector alloc] init];

    // Do any additional setup after loading the view, typically from a nib.
    UIImage * imageDefault = [UIImage imageNamed:@"DefaultFace"];
    
    [self detectorFaces:imageDefault];
    
    [self.previewView setImage:imageDefault];
    
    
    [self.processLabel setHidden:YES];
    [self.processBar setHidden:YES];
   
}

- (void)detectorFaces:(UIImage *)image
{
    cv::Mat imageMat =[FIGOpenCVUtils cvMatWithImage:image];
    
    std::vector<cv::Rect> faces = [self.faceDetector facesFromImage:imageMat];
    
    if (faces.size() != 1) {
        [self noFaceToDisplay];
        return;
    } else {
         self.messageLabel.text = @"";
    }
    
    // We only care about the first face
    cv::Rect face = faces[0];
    
    CGRect faceRect = [FIGOpenCVData faceToCGRect:face];
    
    // set rect image to faceView
    CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], faceRect);
    UIImage *newImage = [UIImage imageWithCGImage:tmp];
    
    [self.faceView setImage:newImage];

    CGImageRelease(tmp);
    
    // Get the application documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Create a filename string with the documents path and our filename
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"mynewimage.png"];
    
    // Save image to disk
    [UIImagePNGRepresentation(newImage) writeToFile:fileName atomically:YES];
    
}


- (void)noFaceToDisplay
{
    [self.faceView setImage:nil];
    self.messageLabel.text = @"No face in image";
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Dismiss the picker
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // See document about the info
    // https://developer.apple.com/library/ios/documentation/uikit/reference/UIImagePickerControllerDelegate_Protocol/UIImagePickerControllerDelegate/UIImagePickerControllerDelegate.html#//apple_ref/doc/constant_group/Editing_Information_Keys
    // Get the image from the result
    // * UIImagePickerControllerOriginalImage
    //Specifies the original, uncropped image selected by the user.
    // The value for this key is a UIImage object.
    //UIImage* imageSelect = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    
    // * UIImagePickerControllerEditedImage
    // Specifies an image edited by the user.
    // The value for this key is a UIImage object.
    UIImage* imageSelect = [info valueForKey:@"UIImagePickerControllerEditedImage"];
    
    [self.previewView setImage:imageSelect];
    
    [self detectorFaces:imageSelect];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonAction:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)selectButtonAction:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)processChanged:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        NSString * info = [userInfo objectForKey:@"info"];
        NSString * number = [userInfo objectForKey:@"process"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.processLabel.text = [NSString stringWithFormat:@"[%@%%]-[%@]", number, info];
        });
    }
    
}

- (IBAction)processFaces:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processChanged:)
     name:@"ProcessLibrary" object:nil];
    
    [self.processLabel setHidden:NO];
    [self.processBar setHidden:NO];
    self.processLabel.text = @"0%";
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [self.processor cleanDatabase];
        [self.processor processAllLibrary];
        
    });
    
}
@end
