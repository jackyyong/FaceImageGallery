//
//  FIGScanViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGAlbumViewController.h"
#import "FIGAlbumDetailViewController.h"
#include <AssetsLibrary/AssetsLibrary.h> 
#import "AssetsDataIsInaccessibleViewController.h"
#import "FIGAlbumCollectionViewCell.h"

@interface FIGAlbumViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end


@implementation FIGAlbumViewController

-(ALAssetsLibrary *) assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(NSMutableArray *) groups{
    if (!_groups) {
        _groups = [[NSMutableArray alloc] init];
    }
    return _groups;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.groups.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"albumCell";
    
    FIGAlbumCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *groupForCell = self.groups[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    
    cell.imageView.image = posterImage;
    cell.imageLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [@(groupForCell.numberOfAssets) stringValue];
    
    return cell;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if([self.groups count] > 0) {
        [self.groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"assetsDataIsInaccessibleViewController"];
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        assetsDataInaccessibleViewController.explanation = errorMessage;
        [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
        }
        else
        {
            [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showAlbumDetail"]) {
        
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        
        if (self.groups.count > (NSUInteger)selectedCell.row) {
            
            // hand off the asset group (i.e. album) to the next view controller
            FIGAlbumDetailViewController *albumDetailViewController = [segue destinationViewController];
            albumDetailViewController.assetsGroup = self.groups[selectedCell.row];
        }
        
        
    }
}


@end
