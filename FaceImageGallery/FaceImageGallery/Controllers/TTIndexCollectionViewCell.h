//
//  TTFaceIndexCollectionViewCell.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTIndexCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *faceImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;

-(void) setFaceImage:(UIImage*)faceImage;
-(void) setBackgroundImage:(UIImage*)backgroundImage;
@end
