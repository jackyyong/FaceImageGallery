//
//  TTFaceModel.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
#import <sqlite3.h>
#import "TTFaceInfo.h"
#import "TTPersonInfo.h"
#import "TTPhotoInfo.h"

@interface TTFaceModel : NSObject

- (id)initWithEigenFaceRecognizer;
- (id)initWithFisherFaceRecognizer;
- (id)initWithLBPHFaceRecognizer;

- (void)trainModel;

- (void)learnFace:(cv::Mat&)face personId:(NSInteger)personId;

- (NSDictionary*)recognizeFace:(cv::Mat&)face;

- (NSMutableArray*)getAllPersons;
- (NSMutableArray*)getAllFaces:(BOOL)loadTrainData;
- (TTPersonInfo*)getPerson:(NSUInteger)personId;
- (TTFaceInfo*)getFace:(NSUInteger)faceId loadTrainData:(BOOL)loadTrainData ;

- (void)newPerson:(TTPersonInfo*)person;
- (void)newFace:(TTFaceInfo*)face;
- (void)newPhoto:(TTPhotoInfo*)photo;

- (BOOL)updatePersonRelatedPhotosCount:(NSUInteger)personId;
- (BOOL)updatePersonName:(NSUInteger)personId name:(NSString *)name fromContact:(BOOL)fromContact;

- (BOOL)deleteAllPersons;
- (BOOL)deleteAllFaces;
- (BOOL)deleteAllPhotos;

- (NSUInteger)getNextFaceId;
- (NSUInteger)getNextPhotoId;
- (NSUInteger)getNextPersonId;

@end