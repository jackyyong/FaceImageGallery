//
//  FIGiCarouselViewController.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-30.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface FIGiCarouselAlbumViewController : UIViewController<iCarouselDataSource, iCarouselDelegate>
@property (weak, nonatomic) IBOutlet iCarousel *iCarouselView;

@end
