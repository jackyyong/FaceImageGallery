//
//  TTFaceIndexCollectionViewCell.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewCell.h"

@implementation TTIndexCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
    }
    return self;
}

-(UIImageView*)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
    }
    return _backgroundImageView;
}

-(UIImageView*)faceImageView {
    if (!_faceImageView) {
        _faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0, 100.0)];
    }
    return _faceImageView;
}

-(id) init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

-(void) setFaceImage:(UIImage*)faceImage {
    [self.faceImageView setImage:faceImage];
    [[self contentView] addSubview:self.faceImageView];
     
}

-(void) setBackgroundImage:(UIImage*)backgroundImage {
    [self.backgroundImageView setImage:backgroundImage];
    [[self contentView] addSubview:self.backgroundImageView];

}

-(void)dealloc {
    _faceImageView = nil;
    
    [super dealloc];
}

@end
