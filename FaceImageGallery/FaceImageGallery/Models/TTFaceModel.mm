//
//  TTFaceModel.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTFaceModel.h"
#import "TTOpenCVData.h"

#define TRAIN_FACE_WIDTH  100
#define TRAIN_FACE_HEIGHT 100

@interface TTFaceModel ()
@property (nonatomic, assign) cv::Ptr<cv::FaceRecognizer> model;
@property (nonatomic, assign) sqlite3 * db;
@end

@implementation TTFaceModel

- (id)init
{
    self = [super init];
    if (self) {
        [self loadDatabase];
    }
    
    return self;
}

-(BOOL)recognizeAvailable
{
    if(_recognizeAvailable) {
        _recognizeAvailable = NO;
    }
    return _recognizeAvailable;
}

- (id)initWithEigenFaceRecognizer
{
    self = [self init];
    _model = cv::createEigenFaceRecognizer();
    
    return self;
}

- (id)initWithFisherFaceRecognizer
{
    self = [self init];
    _model = cv::createFisherFaceRecognizer();
    
    return self;
}

- (id)initWithLBPHFaceRecognizer
{
    self = [self init];
    _model = cv::createLBPHFaceRecognizer();
    
    return self;
}

- (void)trainModel
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    const char* selectSQL = "SELECT personId, image FROM T_FACES";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, selectSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int personID = sqlite3_column_int(statement, 0);
            
            int imageSize = sqlite3_column_bytes(statement, 1);
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
            
            cv::Mat faceData = [TTOpenCVData dataToMat:imageData
                                                  width:[NSNumber numberWithInt:TRAIN_FACE_WIDTH]
                                                 height:[NSNumber numberWithInt:TRAIN_FACE_HEIGHT]];
            
            images.push_back(faceData);
            labels.push_back(personID);
        }
    }
    
    sqlite3_finalize(statement);
    
    if (images.size() > 0 && labels.size() > 0) {
        _model->train(images, labels);
        [self setRecognizeAvailable:YES];
    }
    else {
        [self setRecognizeAvailable:NO];
    }
}

- (void)learnFace:(TTFaceInfo*)faceInfo
{
    if (faceInfo) {
        std::vector<cv::Mat> images;
        std::vector<int> labels;
        
        cv::Mat faceData = [TTOpenCVData dataToMat:faceInfo.image
                                             width:[NSNumber numberWithInt:TRAIN_FACE_WIDTH]
                                            height:[NSNumber numberWithInt:TRAIN_FACE_HEIGHT]];
        
        images.push_back(faceData);
        labels.push_back((int)faceInfo.personId);
        
        if (images.size() > 0 && labels.size() > 0) {
            _model->train(images, labels);
            [self setRecognizeAvailable:YES];
        }
        else {
            [self setRecognizeAvailable:NO];
        }
    }
}

- (cv::Mat)pullStandardizedFace:(cv::Rect)face fromImage:(cv::Mat&)image
{
    cv::Mat onlyTheFace;
    
    cv::cvtColor(image(face), onlyTheFace, CV_RGB2GRAY);
    
    cv::resize(onlyTheFace, onlyTheFace, cv::Size(100, 100), 0, 0);
    return onlyTheFace;
}

- (NSDictionary *)recognizeFace:(cv::Rect)face inImage:(cv::Mat&)image
{
    if (self.recognizeAvailable == NO) {
        return nil;
    }
    
    int predictedLabel = -1;
    double confidence = 0.0;
    
    _model->predict([self pullStandardizedFace:face fromImage:image], predictedLabel, confidence);
    
    return @{
             @"personID": [NSNumber numberWithInt:predictedLabel],
             @"confidence": [NSNumber numberWithDouble:confidence]
             };
}

- (NSMutableArray *)getAllPersons
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    const char *findSQL = "SELECT id, name, linkFromContact,showFaceId, relatedPhotosCount FROM T_PERSONS ORDER BY id";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, findSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TTPersonInfo * personInfo = [[TTPersonInfo alloc]init];
            [personInfo setId:sqlite3_column_int(statement, 0)];
            [personInfo setName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
            [personInfo setLinkFromContact:sqlite3_column_int(statement, 2)];
            [personInfo setShowFaceId:sqlite3_column_int(statement, 3)];
            [personInfo setRelatedPhotosCount:sqlite3_column_int(statement, 4)];
            [results addObject:personInfo];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (NSMutableArray *)getAllFaces
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    const char *findSQL = "SELECT id, personId, image,photoId FROM T_FACES ORDER BY id";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_db, findSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TTFaceInfo * faceInfo = [[TTFaceInfo alloc]init];
            [faceInfo setId:sqlite3_column_int(statement, 0)];
            [faceInfo setPersonId:sqlite3_column_int(statement, 1)];
            
            int imageSize = sqlite3_column_bytes(statement, 2);
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 2) length:imageSize];
            
            [faceInfo setImage:imageData];
            [faceInfo setPersonId:sqlite3_column_int(statement, 3)];
            [results addObject:faceInfo];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (TTPersonInfo *)getPerson:(NSInteger) personId
{
    const char *findSQL = "SELECT id, name,linkFromContact,showFaceId,relatedPhotosCount FROM T_PERSONS where id = ?";
    sqlite3_stmt *statement;
    
    TTPersonInfo* person = nil;
    
    if (sqlite3_prepare_v2(_db, findSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, (int)personId);
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            person = [[TTPersonInfo alloc] init];
            [person setId:personId];
            [person setName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
            [person setLinkFromContact:sqlite3_column_int(statement, 2)];
            [person setShowFaceId:sqlite3_column_int(statement, 3)];
            [person setRelatedPhotosCount:sqlite3_column_int(statement, 4)];
        }
    }
    
    sqlite3_finalize(statement);
    
    return person;
}

- (NSInteger)newPerson:(TTPersonInfo *)person {
    if (person) {
        const char *newSQL = "INSERT INTO T_PERSONS (LinkFromContact, ShowFaceId, RelatedPhotosCount) VALUES (?, ?, ?)";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(_db, newSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, person.linkFromContact);
            sqlite3_bind_int(statement, 2, (int)person.showFaceId);
            sqlite3_bind_int(statement, 3, (int)person.relatedPhotosCount);
            sqlite3_step(statement);
        }
        
        sqlite3_finalize(statement);
        
        return sqlite3_last_insert_rowid(_db);
    }
    return 0;
}

- (BOOL)updatePersonRelatedPhotosCount:(NSInteger)personId {
    TTPersonInfo * personInfo = [self getPerson:personId];
    
    if (personInfo) {
        const char *updateSQL = "UPDATE T_PERSONS set RelatedPhotosCount=RelatedPhotosCount+1 Where id = ? ";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(_db, updateSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)personId);
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)updatePersonName:(NSInteger) personId name:(NSString *)name fromContact:(BOOL)fromContact
{
    
    TTPersonInfo * personInfo = [self getPerson:personId];
    
    if (personInfo){
        const char *updateSQL = "UPDATE T_PERSONS set name=?, linkFromContact=? Where id = ? ";
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(_db, updateSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 2, fromContact);
            sqlite3_bind_int(statement, 3, (int)personId);
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
       
        return YES;
    }
    
    return NO;
    
}

- (NSInteger)newFace:(TTFaceInfo *)face
{
    if (face) {
        
        const char *newSQL = "INSERT INTO T_FACES (PersonId, Image, PhotoId) VALUES (?, ?, ?)";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(_db, newSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)face.personId);
            sqlite3_bind_blob(statement, 2, face.image.bytes, (int)face.image.length, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 3, (int)face.photoId);
            sqlite3_step(statement);
        }
        
        sqlite3_finalize(statement);
        
        return sqlite3_last_insert_rowid(_db);
    }
    return 0;

}

- (BOOL)createRelationshipBetween:(NSInteger)personId faceId:(NSInteger)faceId
{
    const char *updateSQL = "UPDATE T_FACES set PersonId=? Where id = ? ";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, updateSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, (int)personId);
        sqlite3_bind_int(statement, 2, (int)faceId);
        sqlite3_step(statement);
    }
    sqlite3_finalize(statement);
    
    return YES;
}

-(BOOL) executeUpdateSQL:(const char *)sql
{
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_db, sql, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_step(statement);
    }
    sqlite3_finalize(statement);
    return YES;

}

- (BOOL)deleteAllPersons
{
    const char *updateSQL = "DELETE FROM T_PERSONS ";
    return [self executeUpdateSQL:updateSQL];
}

- (BOOL)deleteAllFaces
{
    const char *updateSQL = "DELETE FROM T_FACES ";
    return [self executeUpdateSQL:updateSQL];
}

- (BOOL)deleteAllPhotos
{
    const char *updateSQL = "DELETE FROM T_PHOTOS ";
    return [self executeUpdateSQL:updateSQL];
}

- (NSInteger)newPhoto:(TTPhotoInfo *)photo
{
    if (photo) {
        const char *newSQL = "INSERT INTO T_PHOTOS (AbsoluteURL, TakeTime, Width, Height, Latitude, Longitude, Altitude) VALUES (?, ?, ?, ?, ?, ?, ?)";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(_db, newSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [photo.absoluteURL UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [photo.takeTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 3, photo.width);
            sqlite3_bind_int(statement, 4, photo.height);
            sqlite3_bind_double(statement, 5, photo.latitude);
            sqlite3_bind_double(statement, 6, photo.longitude);
            sqlite3_bind_double(statement, 7, photo.altitude);
            sqlite3_step(statement);
        }
        
        sqlite3_finalize(statement);
        
        return sqlite3_last_insert_rowid(_db);
    }
    return 0;
}

- (void)loadDatabase
{
    if (sqlite3_open([[self dbPath] UTF8String], &_db) != SQLITE_OK) {
        NSLog(@"Cannot open the database.");
    }
    
    [self createTablesIfNeeded];
}

- (NSString *)dbPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"tt.sqlite"];
}

- (void)createTablesIfNeeded
{
    const char *personSQL = "CREATE TABLE IF NOT EXISTS T_PERSONS ('id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                                                    "'name' VARCHAR,"
                                                    "'linkFromContact' BOOL, "
                                                    "'showFaceId' INTEGER, "
                                                    "'relatedPhotosCount' INTEGER)";
    if (sqlite3_exec(_db, personSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Persons table could not be created.");
    }
    
    const char *faceSQL = "CREATE TABLE IF NOT EXISTS T_FACES ('id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,"
                                                "'personId' INTEGER, "
                                                "'image' BLOB,"
                                                "'photoId' INTEGER)";
    
    if (sqlite3_exec(_db, faceSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Faces table could not be created.");
    }
    
    const char *photosSQL = "CREATE TABLE IF NOT EXISTS T_PHOTOS ('id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
                                                   "'absoluteURL' VARCHAR, "
                                                   "'takeTime' VARCHAR, "
                                                   "'width' INTEGER, "
                                                   "'height' INTEGER,"
                                                   "'latitude' DOUBLE,"
                                                   "'longitude' DOUBLE,"
                                                   "'altitude' DOUBLE)";
    
    
    if (sqlite3_exec(_db, photosSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Photos table could not be created.");
    }
    
}

@end
