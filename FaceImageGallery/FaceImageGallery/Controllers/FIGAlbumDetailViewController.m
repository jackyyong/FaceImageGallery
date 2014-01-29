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

-(NSMutableArray*)assets{
    if(!_assets) {
         _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if ([self.assets count] > 0) {
        [self.assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"photoCell";
    
    FIGPhotoCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    [cell.imageView setImage:thumbnail];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        
        // hand off the assets of this album to our singleton data source
        [FIGPhotoDetailViewControllerData sharedInstance].photoAssets = self.assets;
        
        // start viewing the image at the appropriate cell index
        FIGPhotoPageViewController *photoPageViewController = [segue destinationViewController];
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        photoPageViewController.startingIndex = selectedCell.row;
    }
}


@end
