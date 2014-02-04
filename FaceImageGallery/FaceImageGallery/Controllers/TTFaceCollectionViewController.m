//
//  TTFaceCollectionViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-5.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTFaceCollectionViewController.h"
#import "TTFaceModel.h"
#import "TTFaceUICollectionViewCell.h"

@interface TTFaceCollectionViewController ()

@property (nonatomic, strong) TTFaceModel *faceModel;
@property (nonatomic, strong) NSMutableArray *faces;

@end


@implementation TTFaceCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(TTFaceModel*) faceModel {
    if(!_faceModel) {
        _faceModel = [[TTFaceModel alloc] init];
    }
    
    return _faceModel;
}

-(NSMutableArray*) faces {
    if(!_faces) {
        _faces = [[NSMutableArray alloc] init];
    }
    
    return _faces;
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.faces count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTFaceInfo* faceInfo = [self.faces objectAtIndex:indexPath.row];
    
    if (faceInfo) {
        static NSString *CellIdentifier = @"faceUICollectionViewCell";
        
        TTFaceUICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UIImage *faceImage = [[UIImage alloc] initWithData:faceInfo.image];
        
        cell.faceView.image = faceImage;
        return cell;
    }
    
    return nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setFaces:[self.faceModel getAllFaces]];
    
}


@end
