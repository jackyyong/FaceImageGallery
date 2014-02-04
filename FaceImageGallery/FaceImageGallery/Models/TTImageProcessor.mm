//
//  TTImageProcessor.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTImageProcessor.h"
#import <CoreLocation/CoreLocation.h>
#import "TTFaceDetector.h"
#import "TTOpenCVData.h"
#import "TTFaceModel.h"
#import "TTPersonInfo.h"
#import "TTFaceInfo.h"
#import "TTPhotoInfo.h"

#define USE_FULL_RESOLUTION_IMAGE NO

@interface TTImageProcessor ()

@property (nonatomic, strong) TTFaceDetector *faceDetector;
@property (nonatomic, strong) TTFaceModel *faceModel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation TTImageProcessor

-(TTFaceDetector *)faceDetector{
    if (!_faceDetector) {
        _faceDetector = [[TTFaceDetector alloc]init];
    }
    
    return _faceDetector;
}

-(NSMutableArray *)albums{
    if (!_albums) {
        _albums = [[NSMutableArray alloc]init];
    }
    
    return _albums;
}

-(NSMutableArray *)photos{
    if (!_photos) {
        _photos = [[NSMutableArray alloc]init];
    }
    
    return _photos;
}

-(NSNumberFormatter *)numberFormatter{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc]init];
        [_numberFormatter setMaximumFractionDigits:2];   // .1f
        [_numberFormatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    }
    
    return _numberFormatter;
}

-(ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    
    return _assetsLibrary;
}


-(TTFaceModel *)faceModel{
    if (!_faceModel) {
        _faceModel = [[TTFaceModel alloc]initWithEigenFaceRecognizer];
        
        [_faceModel trainModel];
        
    }
    
    return _faceModel;
}


-(void)postNotifiyProcess:(NSString *) info totalCount:(NSInteger) totalCount currentIndex:(NSInteger) currentIndex{
    
    float percent = (currentIndex/totalCount);
    
    NSString *percentString = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:percent]];
    
    [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"ProcessLibrary"
                           object:self
     userInfo:@{@"info" : info, @"process" : percentString}];
}

-(NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return _dateFormatter;
}

-(void) processAllLibrary {
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0) {
            [self.albums addObject:group];
        } else {
            [self processAllLibraryInternal];
        }
    };
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"%@", [error domain]);
    };
    
    NSInteger groupTypes = (ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos);
    
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
}

-(void) processAllLibraryInternal{
    NSInteger totalCount = 0;
    
    if ([self.albums count] <= 0) {
        [self postNotifiyProcess:@"No photos found in your phone." totalCount:1 currentIndex:1];
    } else {
        for (int i = 0; i < [self.albums count]; i++) {
            totalCount = totalCount + [[self.albums objectAtIndex:i] numberOfAssets];
        }
        
        [self postNotifiyProcess:[NSString stringWithFormat:@"Found %ld photos in %ld album", totalCount, [self.albums count]] totalCount:totalCount currentIndex:0];
        
        NSInteger currentIndex = 0;
        for (int i = 0; i < [self.albums count]; i++) {
            
            currentIndex = currentIndex + [self processGroup:[self.albums objectAtIndex:i] currentIndex:currentIndex totalCount:totalCount];
            
        }
    }
}

-(NSInteger) processGroup:(ALAssetsGroup*)group {
    return [self processGroup:group currentIndex:1 totalCount:1];
}

-(NSInteger) processGroup:(ALAssetsGroup*)group currentIndex:(NSInteger) currentIndex totalCount:(NSInteger) totalCount {
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.photos addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [group setAssetsFilter:onlyPhotosFilter];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
    });
    
    [self processGroupInternal:group currentIndex:currentIndex totalCount:totalCount];
    
    return [self.photos count];
}

-(void) processGroupInternal:(ALAssetsGroup*)group currentIndex:(NSInteger) currentIndex totalCount:(NSInteger) totalCount {
    NSString * groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    
    NSLog(@"Start Process Group named %@", groupName);
    
    if ([self.photos count] <= 0) {
        [self postNotifiyProcess:@"No photos found in your phone." totalCount:1 currentIndex:1];
    } else {
        
        for (int i = 0; i < [self.photos count]; i++) {
            currentIndex++;
            [self process:[self.photos objectAtIndex:i]];
            
            [self postNotifiyProcess:[NSString stringWithFormat:@"Process %ld/%ld", currentIndex, totalCount] totalCount:totalCount currentIndex:currentIndex];
        }
    }
    
    NSLog(@"End Process Group named %@", groupName);

}

-(void) process:(ALAsset*)asset {
    
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    // 开始处理人脸识别
    
    // 图片地址
    NSString * imageUrlAbsoluteString  = [[assetRepresentation url] absoluteString];
    
    CGImageRef imageForRecRef = nil;
    
    if (USE_FULL_RESOLUTION_IMAGE) {
        imageForRecRef = [assetRepresentation fullResolutionImage];

    } else {
        imageForRecRef = [assetRepresentation fullScreenImage];
        
    }
    
    UIImage *imageForRec = [UIImage imageWithCGImage:imageForRecRef];
    
    cv::Mat imageForRecMat = [TTOpenCVData cvMatFromUIImage:imageForRec];
    
    std::vector<cv::Rect> faces = [self.faceDetector facesFromCVImage:imageForRecMat];
    
    if (!faces.empty()) {
        
        // 全屏图片
        //CGImageRef fullScreenImageRef = [assetRepresentation fullScreenImage];
        
        // 全尺寸图片
        //CGImageRef fullResolutionImageRef = [assetRepresentation fullResolutionImage];
        //UIImage *fullResolutionImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]];
        
        // 图片大小
        CGSize dimensions = [assetRepresentation dimensions];
        
        // 图片地址
        NSString * absoluteURL  = [[assetRepresentation url] absoluteString];
        
        // 图片拍摄时间
        NSDate * takeDate = [asset valueForProperty:ALAssetPropertyDate];
        
        // 图片拍摄位置
        CLLocation * takeLocation =[asset valueForProperty:ALAssetPropertyLocation];
        
        TTPhotoInfo* photoInfo = [self createPhotoInfo:absoluteURL takeTime:takeDate dimensions:dimensions location:takeLocation];
        
        // new photo
        NSInteger photoId = [self.faceModel newPhoto:photoInfo];
        
        NSLog(@"Start process and found %ld faces in image %@", faces.size(), imageUrlAbsoluteString);
        
        for (std::vector<cv::Rect>::iterator iter = faces.begin(); iter != faces.end(); ++iter) {
            [self processSingleFace: *iter inImage:imageForRecMat assetInfo:asset photoId:photoId];
        }
        
        NSLog(@"End process and found %ld faces in image %@", faces.size(), imageUrlAbsoluteString);
        
    } else {
        NSLog(@"Because of no faces found, so ignore photos with url  %@", imageUrlAbsoluteString);
    }
}

// 处理单个面孔
-(void) processSingleFace:(cv::Rect)face inImage:(cv::Mat&)image assetInfo:(ALAsset*)asset photoId:(NSInteger)photoId  {
    // to find
    NSDictionary * match = [self.faceModel recognizeFace:face inImage:image];
    
    cv::Mat faceDataMat = [self.faceModel pullStandardizedFace:face fromImage:image];
    
    NSData *faceData = [TTOpenCVData serializeCvMat:faceDataMat];
    
    TTFaceInfo *faceInfo = nil;
    NSInteger newFaceId;
    // Match found
    if (match && [match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
        
        NSInteger personId = (NSInteger)[match objectForKey:@"personID"];
        
        // new face
        faceInfo = [self createFaceInfo:personId photoId:photoId image:faceData];
        
        newFaceId = [self.faceModel newFace:faceInfo];
        
        NSLog(@"[Matched]Person:%ld Face:%ld", personId, newFaceId);
        
        // update person
        [self.faceModel updatePersonRelatedPhotosCount:personId];
    } else {
        // new face
        faceInfo = [self createFaceInfo:0 photoId:photoId image:faceData];
        newFaceId = [self.faceModel newFace:faceInfo];
        
        // new person
        TTPersonInfo *personInfo = [self createPersonInfo:newFaceId];
        NSInteger newPersonId = [self.faceModel newPerson:personInfo];
        
        NSLog(@"[NotMatched]Person:%ld Face:%ld", newPersonId, newFaceId);
        
        // update face with personid, set face's personid with newfaceid
        [self.faceModel createRelationshipBetween:newPersonId faceId:newFaceId];
        
        [faceInfo setPersonId:newPersonId];
    }
    
    
    UIImage *imageToSave = [[UIImage alloc] initWithData:faceData];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%ld.png", docDir, newFaceId];
    
	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageToSave)];
    
	[data1 writeToFile:pngFilePath atomically:YES];
    
    
    // save new face to file
    
    NSLog(@"Train new face start.");
    
    [self.faceModel learnFace:faceInfo];
    
    NSLog(@"Train new face end.");

}

-(void) cleanDatabase {
    [self.faceModel deleteAllPersons];
    [self.faceModel deleteAllFaces];
    [self.faceModel deleteAllPhotos];
}

-(TTPhotoInfo*)createPhotoInfo:(NSString*)absoluteURL takeTime:(NSDate*)takeDate dimensions:(CGSize)dimensions location:(CLLocation *)takeLocation {
    // create new photo
    TTPhotoInfo * photoInfo = [[TTPhotoInfo alloc] init];
    [photoInfo setTakeTime:[self.dateFormatter stringFromDate:takeDate]];
    [photoInfo setAbsoluteURL:absoluteURL];
    [photoInfo setWidth:dimensions.width];
    [photoInfo setHeight:dimensions.height];
    
    if (takeLocation) {
        [photoInfo setLatitude:takeLocation.coordinate.latitude];
        [photoInfo setLongitude:takeLocation.coordinate.longitude];
        [photoInfo setAltitude:takeLocation.altitude];
    }
    
    return photoInfo;
}


-(TTPersonInfo*)createPersonInfo:(NSInteger)showFaceId  {
    // create new photo
    TTPersonInfo * personInfo = [[TTPersonInfo alloc] init];
    
    [personInfo setLinkFromContact:NO];
    [personInfo setShowFaceId:showFaceId];
    [personInfo setName:@"未标记"];
    [personInfo setRelatedPhotosCount:1];
    
    return personInfo;
}


-(TTFaceInfo*)createFaceInfo:(NSInteger) personId  photoId:(NSInteger) photoId image:(NSData*)image {
    // create new face
    TTFaceInfo * faceInfo = [[TTFaceInfo alloc] init];
    
    [faceInfo setPersonId:personId];
    [faceInfo setPhotoId:photoId];
    [faceInfo setImage:image];
    
    return faceInfo;
}

@end
