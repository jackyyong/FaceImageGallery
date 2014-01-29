//
//  FIGPhotoAlbumDetailCollectionViewController.h
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FIGAlbumDetailViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
