//
//  FIGPhotoAlbumDetailCollectionViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGAlbumDetailViewController.h"
#import "FIGPhotoPageViewController.h"
#import "FIGPhotoDetailViewControllerData.h"
#import "FIGPhotoCollectionViewCell.h"
@interface FIGAlbumDetailViewController ()

@end

@implementation FIGAlbumDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title =  self.albumInfo.albumName;
    
    if ([self.albumInfo getPhotosCount] > 0) {
        [self.albumInfo removeAllPhotos];
    }
    
    [self.albumInfo readPhotos];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.albumInfo getPhotosCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    FIGPhotoCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    
    
    CGImageRef thumbnailImageRef = [[self.albumInfo getPhotoInfoAtIndex:indexPath.row] thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    [cell.imageView setImage:thumbnail];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        
        // hand off the assets of this album to our singleton data source
        [FIGPhotoDetailViewControllerData sharedInstance].photoAssets = self.albumInfo.photos;
        
        // start viewing the image at the appropriate cell index
        FIGPhotoPageViewController *photoPageViewController = [segue destinationViewController];
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        photoPageViewController.startingIndex = selectedCell.row;
    }
}


@end
