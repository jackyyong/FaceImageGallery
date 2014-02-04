//
//  FIGAlbumReader.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-1.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGAlbumReader.h"

@interface FIGAlbumReader ()

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger groupTypes;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *albumInfoCaches;

@end

@implementation FIGAlbumReader

- (void)setDelegate:(id)aDelegate {
    _delegate = aDelegate;
}

-(id)init {
   return [self initWithAlbumTypes: (ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos)];
}

-(id)initWithAlbumTypes: (NSInteger) groupTypes {
    self = [super init];
    
    if(!self) {
        return nil;
    };
    
    [self setGroupTypes:groupTypes];
    
    return self;
}

-(void)readAlbums {
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0) {
            [self.albums addObject:group];
            // init albums cache
            
        } else {
            [self.delegate whenReaderSuccess];
        }
    };
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [self.delegate whenReaderFailture:error];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // enumerate only photos
        [self.assetsLibrary enumerateGroupsWithTypes:self.groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    });
    
}

-(ALAssetsLibrary *) assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(NSMutableArray *) albums{
    if (!_albums) {
        _albums = [[NSMutableArray alloc] init];
    }
    return _albums;
}

-(NSMutableArray *) albumInfoCaches{
    if (!_albumInfoCaches) {
        _albumInfoCaches = [NSMutableArray arrayWithCapacity: 128];
    }
    return _albumInfoCaches;
}


-(NSInteger) getAlbumCount {
    return self.albums.count;
}

-(FIGAlbumInfo *)getAlbumInfoAtIndex:(NSInteger) index {
    ALAssetsGroup * groupForCell = self.albums[index];
    // TODO need to cache
    if (groupForCell) {
        FIGAlbumInfo * info = nil;
        if (!info) {
            info = [[FIGAlbumInfo alloc] init];
            info.posterImage = [groupForCell posterImage];
            info.albumName = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
            info.numberOfPhotos = groupForCell.numberOfAssets;
            info.assetsGroup = groupForCell;
        }
        return info;
    } else {
        return nil;
    }
}

-(void)removeAllAlbums {
    [self.albums removeAllObjects];
    [self.albumInfoCaches removeAllObjects];
}

@end
