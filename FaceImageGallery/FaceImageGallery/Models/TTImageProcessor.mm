//
//  TTImageProcessor.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TTImageProcessor.h"
#import "TTFaceDetector.h"
#import "TTOpenCVData.h"
#import "TTFaceModel.h"
#import "TTPersonInfo.h"
#import "TTFaceInfo.h"
#import "TTPhotoInfo.h"
#import "TTCst.h"

@interface TTImageProcessor ()

    //人脸探测器
@property (nonatomic, strong) TTFaceDetector *faceDetector;

    //人脸模型
@property (nonatomic, strong) TTFaceModel *faceModel;

    //日期格式化
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

    //数字格式化
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

    //相册库引用
@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;

@end

@implementation TTImageProcessor

-(void)dealloc {
    
    [_dateFormatter release];
    _dateFormatter = nil;
    
    [_assetsLibrary release];
    _assetsLibrary = nil;
    
    [_numberFormatter release];
    _numberFormatter = nil;
    
    
    [super dealloc];
}

-(TTFaceDetector *)faceDetector{
    if (!_faceDetector) {
        _faceDetector = [[TTFaceDetector alloc]init ];
    }
    
    return _faceDetector;
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

-(NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return _dateFormatter;
}

-(id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNewAlbumFound:) name:EVENT_NEW_GROUP_FOUND object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNewAssetFound:) name:EVENT_NEW_ASSET_FOUND object:nil];
    }
    
    return self;
}

// 当发现新相册时, 调用此函数, 此函数处理新发现的相册
-(void) whenNewAlbumFound :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        ALAssetsGroup * group = [userInfo objectForKey:EVENT_NGF_ARG_GROUP];
        NSLog(@"Start process group %@ ", [group valueForProperty:ALAssetsGroupPropertyName]);
        [self processGroup:group];
        NSLog(@"End process group %@ ", [group valueForProperty:ALAssetsGroupPropertyName]);
    }
}

-(void) whenNewAssetFound :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        ALAsset * asset = [userInfo objectForKey:EVENT_NSF_ARG_ASSET];
        NSLog(@"Start process asset %@ ", [asset valueForProperty:ALAssetPropertyAssetURL]);
        [self process:asset];
        NSLog(@"End process asset %@ ", [asset valueForProperty:ALAssetPropertyAssetURL]);
    }
}

-(BOOL) isDatabaseCreated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * lastUpdateTimeStr = [userDefaults objectForKey:@"LastUpdateTime"];
    
    if (lastUpdateTimeStr) {
        return YES;
    } else {
        return NO;
    }
}

-(void) processAllLibrary {
    // update last scan time
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:[self.dateFormatter stringFromDate:[NSDate date]] forKey:@"LastUpdateTime"];
    
    [self cleanDatabase];
    
    NSInteger groupTypes = (ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos);
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:onlyPhotosFilter];
            if ([group numberOfAssets] > 0) {
                // Just Notify
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:EVENT_NEW_GROUP_FOUND
                 object:self
                 userInfo:@{EVENT_NGF_ARG_GROUP : group}];
                
                if ([self.delegate respondsToSelector:@selector(whenNewGroupFound:)]) {
                    [self.delegate whenNewGroupFound:group];
                }
            }
        }
        failureBlock:^(NSError *error) {
            NSLog(@"%@", [error domain]);
   }];
}


-(void) processGroup:(ALAssetsGroup*)group {
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [group setAssetsFilter:onlyPhotosFilter];
    
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {
            // Just Notify
            [[NSNotificationCenter defaultCenter]
                                    postNotificationName:EVENT_NEW_ASSET_FOUND
                                    object:self
                                    userInfo:@{EVENT_NSF_ARG_ASSET : asset}];
            
            if ([self.delegate respondsToSelector:@selector(whenNewAssetFound:)]) {
                [self.delegate whenNewAssetFound:asset];
            }
            
        }
    }];
}

-(void) process:(ALAsset*)asset {
    
    // 开始处理人脸识别
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    CGImageRef imageForRecRef = nil;
    
    if (USE_FULL_RESOLUTION_IMAGE) {
        imageForRecRef = [assetRepresentation fullResolutionImage];
    } else {
        imageForRecRef = [assetRepresentation fullScreenImage];
    }
    
    UIImage *imageForRec = [UIImage imageWithCGImage:imageForRecRef];
    
    // 彩色照片转换成灰度Mat
    cv::Mat imageForRecMatGray = [TTOpenCVData CVMatFromUIImage:imageForRec usingColorSpace:CV_RGB2GRAY];
    
    cv::Mat imageForRecMat = [TTOpenCVData CVMatFromUIImage:imageForRec];
    
    // 从图片中提取人脸
    std::vector<cv::Rect> faces = [self.faceDetector facesFromCVImage:imageForRecMatGray];
    
    if (!faces.empty()) {
        
        // 保存新图片信息
        NSUInteger newPhotoId = [self.faceModel getNextPhotoId];
        
        TTPhotoInfo* photoInfo = [self createPhotoInfo:newPhotoId
                                           absoluteURL:[[assetRepresentation url] absoluteString] //图片地址
                                              takeTime:[asset valueForProperty:ALAssetPropertyDate] //图片拍摄时间
                                           dimensions:[assetRepresentation dimensions] // 图片大小
                                              location:[asset valueForProperty:ALAssetPropertyLocation]//拍摄位置
                                                 scale:[assetRepresentation scale]
                                  ];
        
        [self.faceModel newPhoto:photoInfo];
        
        [photoInfo release];
        
        NSLog(@"Process %ld faces start", faces.size());
        
        // 处理每一张人脸
        for (std::vector<cv::Rect>::iterator iter = faces.begin(); iter != faces.end(); ++iter) {
            [self processSingleFace: *iter              //人脸矩形
                            inImage:imageForRecMat      //原图mat
                        inImageGray:imageForRecMatGray  //灰度图mat
                          assetInfo:asset               //asset
                            photoId:newPhotoId          //新图片id
             ];
        }
        NSLog(@"Process %ld faces end ", faces.size());

    }
    
    if ([self.delegate respondsToSelector:@selector(whenNewAssetProcessEnd:)]) {
        [self.delegate whenNewAssetProcessEnd:asset];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:EVENT_NEW_ASSET_PROCESS_END
     object:self
     userInfo:@{EVENT_NAPE_ARG_ASSET : asset}];
    
}

// 处理单个面孔
-(void) processSingleFace:(cv::Rect)face inImage:(cv::Mat&)image inImageGray:(cv::Mat&)imageGray assetInfo:(ALAsset*)asset photoId:(NSUInteger)photoId  {
    
    cv::Mat standardizedFaceGray  = [TTOpenCVData pullStandardizedFace:face fromImage:imageGray];
    
    // 匹配人脸
    NSDictionary * match = [self.faceModel recognizeFace:standardizedFaceGray];
    
    //next faceid
    TTFaceInfo *faceInfo = nil;
    NSUInteger newFaceId = [self.faceModel getNextFaceId];
    // 保存彩色图片到文件系统
    NSString * newFaceImage = [self saveFacePNGToFileSystem:face inImage:image faceId:newFaceId];
    
    if ([self.delegate respondsToSelector:@selector(whenNewFaceFound:)]) {
        [self.delegate whenNewFaceFound:newFaceId];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:EVENT_NEW_FACE_FOUND
     object:self
     userInfo:@{EVENT_NFF_ARG_FACEID : [NSNumber numberWithInteger:newFaceId]}];
    
    NSUInteger personId = nil;
    NSNumber * confidence = nil;
    
    // Match found
    if (match && [match objectForKey:@"personID"] != [NSNumber numberWithInt:-1]) {
        
        NSString * confidenceStr = [NSString stringWithFormat:@"Confidence: %@",
                      [self.numberFormatter stringFromNumber:[match objectForKey:@"confidence"]]];
        
        NSLog(@"confidence = %@ ", confidenceStr);
        
        confidence = [match objectForKey:@"confidence"];
        
        if ([confidence doubleValue] > 0.5) {
            personId = (NSUInteger)[match objectForKey:@"personID"];
            
            NSLog(@"[Matched]Person:%lu Face:%lu", personId, newFaceId);
            
            [self.faceModel updatePersonRelatedPhotosCount:personId];
        }
        
    }
    
     // is new person
    if (!personId) {
        // new person
        personId = [self.faceModel getNextPersonId];
        TTPersonInfo *personInfo = [self createPersonInfo:personId showFaceId:newFaceId];
        
        [self.faceModel newPerson:personInfo];
        
        if ([self.delegate respondsToSelector:@selector(whenNewPersonFound:)]) {
            [self.delegate whenNewPersonFound:personId];
        }
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:EVENT_NEW_PERSON_FOUND
         object:self
         userInfo:@{EVENT_NPF_ARG_PERSONID : [NSNumber numberWithInteger:personId]}];
        
        NSLog(@"[NotMatched]Person:%ld Face:%ld", personId, newFaceId);
        
        [personInfo release];
    }
    
    NSData *serialized = [TTOpenCVData NSDataFromCVMat:standardizedFaceGray];
    
    // new face
    faceInfo = [self createFaceInfo:newFaceId personId:personId photoId:photoId image:newFaceImage trainData:serialized faceRect:face confidence:confidence];
    
    [self.faceModel newFace:faceInfo];
    
    NSLog(@"Train new face start.");
    //Just for train
    
    [self.faceModel learnFace:standardizedFaceGray personId:personId];
    
    [faceInfo release];
    
    NSLog(@"Train new face end.");
    
}

-(NSString*) saveFacePNGToFileSystem:(cv::Rect)face inImage:(cv::Mat&)image faceId:(NSUInteger)faceId {
    cv::Mat faceMat;
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = nil;
    NSString *parentFolder = [NSString stringWithFormat:@"%@/faces", docDir];
    
    faceMat = [TTOpenCVData pullStandardizedFace:face fromImage:image];
    pngFilePath = [NSString stringWithFormat:@"%@/%ld.png", parentFolder, faceId];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:parentFolder isDirectory:nil]) {
        BOOL success = [fileManager createDirectoryAtPath:parentFolder withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"success 1: %i", success);
    }
    
    UIImage *imageToSave = [TTOpenCVData UIImageFromCVMat:faceMat];
    
    NSData *dataToSave = [NSData dataWithData:UIImagePNGRepresentation(imageToSave)];
    
    NSLog(@"Start wirte file to %@.", pngFilePath);
    
    [fileManager createFileAtPath:pngFilePath contents:dataToSave attributes:nil];
    
    NSLog(@"End wirte file to %@.", pngFilePath);
    
    return pngFilePath;
}

-(void) cleanDatabase {
    [self.faceModel deleteAllPersons];
    [self.faceModel deleteAllFaces];
    [self.faceModel deleteAllPhotos];
    //
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *parentFolder = [NSString stringWithFormat:@"%@/faces", docDir];
    
    if (![fileManager fileExistsAtPath:parentFolder isDirectory:nil]) {
        NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:parentFolder];
        
        NSError* err = nil;
        BOOL res;
        NSString* file;
        while (file = [en nextObject]) {
            res = [fileManager removeItemAtPath:[parentFolder stringByAppendingPathComponent:file] error:&err];
            if (!res && err) {
                NSLog(@"oops: %@", err);
            }
        }
        
    }
}

-(TTPhotoInfo*)createPhotoInfo:(NSUInteger) photoId absoluteURL:(NSString*)absoluteURL takeTime:(NSDate*)takeDate dimensions:(CGSize)dimensions location:(CLLocation *)takeLocation scale:(float)scale{
    // create new photo
    TTPhotoInfo * photoInfo = [[TTPhotoInfo alloc] init];
    [photoInfo setTakeTime:[self.dateFormatter stringFromDate:takeDate]];
    [photoInfo setAbsoluteURL:absoluteURL];
    [photoInfo setWidth:dimensions.width];
    [photoInfo setHeight:dimensions.height];
    [photoInfo setId:photoId];
    [photoInfo setScale:scale];
    
    if (takeLocation) {
        [photoInfo setLatitude:takeLocation.coordinate.latitude];
        [photoInfo setLongitude:takeLocation.coordinate.longitude];
        [photoInfo setAltitude:takeLocation.altitude];
    }
    
    return photoInfo;
}


-(TTPersonInfo*)createPersonInfo:(NSUInteger)personId showFaceId:(NSUInteger)showFaceId  {
    // create new photo
    TTPersonInfo * personInfo = [[TTPersonInfo alloc] init];
    
    [personInfo setLinkFromContact:NO];
    [personInfo setShowFaceId:showFaceId];
    [personInfo setName:@"未标记"];
    [personInfo setRelatedPhotosCount:1];
    [personInfo setId:personId];
    
    return personInfo;
}


-(TTFaceInfo*)createFaceInfo:(NSUInteger) newFaceId personId:(NSUInteger)personId photoId:(NSUInteger)photoId image:(NSString*)image trainData:(NSData*)trainData faceRect:(cv::Rect)faceRect confidence:(NSNumber*)confidence{
    // create new face
    TTFaceInfo * faceInfo = [[TTFaceInfo alloc] init];
    
    [faceInfo setId:newFaceId];
    [faceInfo setPersonId:personId];
    [faceInfo setPhotoId:photoId];
    [faceInfo setImage:image];
    
    [faceInfo setTrainData:trainData];
    [faceInfo setConfidence:[confidence doubleValue]];
    [faceInfo setRectX:faceRect.x];
    [faceInfo setRectY:faceRect.y];
    [faceInfo setRectWidth:faceRect.width];
    [faceInfo setRectHeight:faceRect.height];
    
    return faceInfo;
}

@end
