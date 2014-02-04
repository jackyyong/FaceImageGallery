//
//  FIGScanViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGAlbumViewController.h"
#import "FIGAlbumDetailViewController.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "FIGAlbumCollectionViewCell.h"
#import "FIGAlbumReader.h"

@interface FIGAlbumViewController ()

@property (nonatomic, strong) FIGAlbumReader *reader;

@end


@implementation FIGAlbumViewController

-(FIGAlbumReader*) reader {
    if(!_reader) {
        _reader = [[FIGAlbumReader alloc] init];
    }
    
    return _reader;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.reader getAlbumCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FIGAlbumInfo* albumInfo = [self.reader getAlbumInfoAtIndex:indexPath.row];
    
    if (albumInfo) {
        static NSString *CellIdentifier = @"albumCell";
        
        FIGAlbumCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImage *posterImage = [UIImage imageWithCGImage:albumInfo.posterImage];
        
        cell.imageView.image = posterImage;
        cell.imageLabel.text = albumInfo.albumName;
        cell.detailTextLabel.text = [@(albumInfo.numberOfPhotos) stringValue];
         return cell;
    }
   
    return nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	if([self.reader getAlbumCount] > 0) {
        [self.reader removeAllAlbums];
    }
    
    [self.reader readAlbums];
    
}

- (void)whenReaderFailture:(NSError *)error {
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
}

- (void)whenReaderSuccess {
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.reader setDelegate:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showAlbumDetail"]) {
        
        NSIndexPath *selectedCell = [self.collectionView indexPathsForSelectedItems][0];
        
        if ([self.reader getAlbumCount] > (NSUInteger)selectedCell.row) {
            
            // hand off the asset group (i.e. album) to the next view controller
            FIGAlbumDetailViewController *albumDetailViewController = [segue destinationViewController];
            albumDetailViewController.albumInfo = [self.reader getAlbumInfoAtIndex: selectedCell.row];
        }
        
        
    }
}


@end
