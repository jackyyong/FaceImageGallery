//
//  TTIndexCollectionViewDelegate.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewDelegate.h"

@implementation TTIndexCollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select %ld", indexPath.row);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deselect %ld", indexPath.row);
}

@end
