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

@property (nonatomic, assign) BOOL recognizeAvailable;

- (id)initWithEigenFaceRecognizer;
- (id)initWithFisherFaceRecognizer;
- (id)initWithLBPHFaceRecognizer;
- (void)trainModel;
- (void)learnFace:(TTFaceInfo*)faceInfo;
- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image;
- (NSDictionary*)recognizeFace:(cv::Rect)face inImage:(cv::Mat&)image;
- (NSInteger)newPerson:(TTPersonInfo*)person;
- (BOOL)createRelationshipBetween:(NSInteger)personId faceId:(NSInteger)faceId;
- (BOOL)updatePersonName:(NSInteger) personId name:(NSString *)name fromContact:(BOOL)fromContact;
- (BOOL)updatePersonRelatedPhotosCount:(NSInteger)personId;
- (NSInteger)newFace:(TTFaceInfo*)face;
- (NSInteger)newPhoto:(TTPhotoInfo*)photo;
- (BOOL)deleteAllPersons;
- (BOOL)deleteAllFaces;
- (BOOL)deleteAllPhotos;
- (NSMutableArray*)getAllPersons;
- (NSMutableArray*)getAllFaces;

@end