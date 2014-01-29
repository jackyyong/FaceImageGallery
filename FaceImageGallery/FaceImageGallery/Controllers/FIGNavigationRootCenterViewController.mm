//
//  FIGCenterViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGNavigationRootCenterViewController.h"
#import <opencv2/highgui/cap_ios.h>
#import "FIGOpenCVUtils.h"
#import "FIGOpenCVData.h"

@interface FIGNavigationRootCenterViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *faceView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)cameraButtonAction:(UIButton *)sender;
- (IBAction)selectButtonAction:(UIButton *)sender;

@end


@implementation FIGNavigationRootCenterViewController

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

    // Do any additional setup after loading the view, typically from a nib.
    UIImage * imageDefault = [UIImage imageNamed:@"DefaultFace"];
    
    [self detectorFaces:imageDefault];
    
    [self.previewView setImage:imageDefault];
   
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
@end
