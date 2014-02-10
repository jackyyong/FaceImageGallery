//
//  TTIndexCollectionViewLayoutAttributes.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTIndexCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

// whether header view (ConferenceHeader class) should align label left or center (default = left)
@property (nonatomic, assign) NSTextAlignment headerTextAlignment;

// shadow opacity for the shadow on the photo in SpeakerCell (default = 0.5)
@property (nonatomic, assign) CGFloat shadowOpacity;

@end
