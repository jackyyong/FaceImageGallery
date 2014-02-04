//
//  FIGAlbumInfo.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-1.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGAlbumInfo.h"

@interface FIGAlbumInfo ()

@property (nonatomic, strong) NSMutableArray *photoInfoCaches;

@end

@implementation FIGAlbumInfo

-(NSMutableArray*)photos{
    if(!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

-(NSMutableArray *) photoInfoCaches{
    if (!_photoInfoCaches) {
        _photoInfoCaches = [NSMutableArray arrayWithCapacity: 128];
    }
    return _photoInfoCaches;
}

- (void)setAssetsFilter:(ALAssetsFilter *)filter {
    
}

-(void)readPhotos {
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.photos addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}


- (void)removeAllPhotos {
    [self.photos removeAllObjects];
}

- (NSInteger) getPhotosCount {
    return [self.photos count];
}

-(FIGPhotoInfo * )getPhotoInfoAtIndex:(NSInteger) index {
    ALAsset * photo = self.photos[index];
    // TODO need to cache
    FIGPhotoInfo * info = nil;
    if (photo) {
        
        if ([self.photoInfoCaches count] > index) {
            info = [self.photoInfoCaches objectAtIndex:index];
        }
        
        if (!info) {
            info = [[FIGPhotoInfo alloc] init];
            
            info.thumbnail = photo.thumbnail;
        
            [self.photoInfoCaches insertObject:info atIndex:index];
        }
        
        return info;
    } else {
        return nil;
    }

}


@end

