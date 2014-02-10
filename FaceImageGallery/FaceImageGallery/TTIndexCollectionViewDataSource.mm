//
//  TTIndexCollectionViewDataSource.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewDataSource.h"
#import "TTIndexCollectionViewCell.h"
#import "TTCst.h"
#import "TTFaceModel.h"
#import "TTIndexCollectionViewCell.h"

@interface TTIndexCollectionViewDataSource ()
@property (nonatomic, strong) TTFaceModel *faceModel;
@property (nonatomic, strong) NSMutableArray *persons;
@end

@implementation TTIndexCollectionViewDataSource
#pragma mark - UICollectionViewDataSource

-(TTFaceModel*) faceModel {
    if(!_faceModel) {
        _faceModel = [[TTFaceModel alloc] init];
    }
    return _faceModel;
}

-(NSMutableArray*) persons {
    if(!_persons) {
        _persons = [[NSMutableArray alloc] init];
    }
    
    return _persons;
}

-(id)init {
    self = [super init];
    
    if (self) {
        [self setPersons:[self.faceModel getAllPersons]];
    }
    
    return self;
}

-(void)reloadData {
    [self.persons removeAllObjects];
    [self setPersons:[self.faceModel getAllPersons]];
}

    // 返回分组数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// 返回某分组的元素数量
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger personCount = [self.persons count];
    return (personCount > INDEX_TOTAL_PERPAGE) ? personCount : INDEX_TOTAL_PERPAGE;
}

-(NSData*)getImageDataFromFS:(NSString*)path {
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

// 返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // section - 分组序号
    //序号 indexPath.item
    //NSInteger section = indexPath.section;
    
NSInteger row = indexPath.row;
    
        //UIImage * imagebackground = [UIImage imageNamed:backgroundImageName];
    TTPersonInfo* personInfo = nil;
    if (row < [self.persons count]) {
        personInfo = [self.persons objectAtIndex:row];
    }
    
    TTIndexCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:INDEX_COLLECTION_REUSABLECellCELL_NAME forIndexPath:indexPath];
    
    UIImage * backgruondImage = [UIImage imageNamed:INDEX_BACKGROUND_IMAGE];
    
    if (personInfo) {
        
        TTFaceInfo * faceInfo = [self.faceModel getFace:personInfo.showFaceId loadTrainData:NO];
        
        NSData* imageData = [self getImageDataFromFS:faceInfo.image];
        
        UIImage *faceImage = [[UIImage alloc] initWithData:imageData scale:100.0/336.0];
        
        [cell setBackgroundImage:backgruondImage];
        [cell setFaceImage:faceImage];
        
        [faceImage release];
        
    } else {
        [cell setBackgroundImage:backgruondImage];
        
    }
    
    return cell;
    
}

-(UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//返回Header/Footer
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end
