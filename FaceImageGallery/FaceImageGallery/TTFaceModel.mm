//
//  TTFaceModel.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-3.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTFaceModel.h"
#import "TTOpenCVData.h"

@interface TTFaceModel ()

@property (assign, nonatomic) sqlite3 * db;
@property (assign, nonatomic) cv::Ptr<cv::FaceRecognizer> model;
@property (assign, nonatomic) BOOL recognizeAvailable;
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

- (BOOL)recognizeAvailable
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

-(NSData*)getImageTrainDataFromFS:(NSString*)path {
   return [NSData dataWithContentsOfFile:path];
}

- (void)trainModel
{
    std::vector<cv::Mat> images;
    std::vector<int> labels;
    
    sqlite3_stmt *statement;
    
    const char *SelectFaceForTrainSQL = "SELECT personId, TrainData FROM T_FACES";
    
    if (sqlite3_prepare_v2(_db, SelectFaceForTrainSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int personID = sqlite3_column_int(statement, 0);
            
                // First pull out the image into NSData
            int imageSize = sqlite3_column_bytes(statement, 1);
            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
            
            cv::Mat faceData = [TTOpenCVData CVMatStandardizedFromNSData:imageData];
            
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

- (void)learnFace:(cv::Mat&)face personId:(NSInteger)personId;
{
        std::vector<cv::Mat> images;
        std::vector<int> labels;
        images.push_back(face);
        labels.push_back((int)personId);
        
        if (images.size() > 0 && labels.size() > 0) {
            _model->train(images, labels);
            [self setRecognizeAvailable:YES];
        }
        else {
            [self setRecognizeAvailable:NO];
        }
}

- (NSDictionary*)recognizeFace:(cv::Mat&)face
{
    if (!_recognizeAvailable) {
        return nil;
    }
    
    int predictedLabel = -1;
    double confidence = 0.0;
    
    _model->predict(face,
                    predictedLabel,
                    confidence);
    
    return @{@"personID": [NSNumber numberWithInt:predictedLabel],
             @"confidence": [NSNumber numberWithDouble:confidence]};
}

- (NSMutableArray *)getAllPersons
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    
    const char *SelectAllPersonSQL = "SELECT id, name, linkFromContact,showFaceId, relatedPhotosCount FROM T_PERSONS ORDER BY id";
    
    if (sqlite3_prepare_v2(_db, SelectAllPersonSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TTPersonInfo * personInfo = [[TTPersonInfo alloc]init];
            [personInfo setId:sqlite3_column_int(statement, 0)];
            
            [personInfo setName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)]];
            
            [personInfo setLinkFromContact:sqlite3_column_int(statement, 2)];
            [personInfo setShowFaceId:sqlite3_column_int(statement, 3)];
            [personInfo setRelatedPhotosCount:sqlite3_column_int(statement, 4)];
            
            [results addObject:personInfo];
            
            [personInfo release];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (NSMutableArray *)getAllFaces:(BOOL)loadTrainData
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    
    const char *SelectAllFaceSQL = "SELECT id, personId, image, TrainData, photoId,rectX,rectY,rectWidth,rectHeight FROM T_FACES ORDER BY id";
    
    if (sqlite3_prepare_v2(_db, SelectAllFaceSQL, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            TTFaceInfo * faceInfo = [[TTFaceInfo alloc]init];
            [faceInfo setId:sqlite3_column_int(statement, 0)];
            [faceInfo setPersonId:sqlite3_column_int(statement, 1)];
            [faceInfo setImage:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
            
            if (loadTrainData) {
                 // First pull out the image into NSData
                int imageSize = sqlite3_column_bytes(statement, 3);
                NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 3) length:imageSize];
                [faceInfo setTrainData:imageData];
            }
            
            [faceInfo setPersonId:sqlite3_column_int(statement, 4)];
            [faceInfo setRectX:sqlite3_column_int(statement, 5)];
            [faceInfo setRectY:sqlite3_column_int(statement, 6)];
            [faceInfo setRectWidth:sqlite3_column_int(statement, 7)];
            [faceInfo setRectHeight:sqlite3_column_int(statement, 8)];
            [results addObject:faceInfo];
            
            [faceInfo release];
        }
    }
    
    sqlite3_finalize(statement);
    
    return results;
}

- (TTPersonInfo *)getPerson:(NSUInteger) personId
{
    const char *FindPersonsSQL = "SELECT id, name,linkFromContact,showFaceId,relatedPhotosCount FROM T_PERSONS where id = ?";
    sqlite3_stmt *statement;
    
    TTPersonInfo* person = nil;
    
    if (sqlite3_prepare_v2(_db, FindPersonsSQL, -1, &statement, nil) == SQLITE_OK) {
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

- (TTFaceInfo*)getFace:(NSUInteger)faceId loadTrainData:(BOOL)loadTrainData {
    TTFaceInfo * faceInfo = nil;
    sqlite3_stmt *statement;
    
    const char *SelectAllFaceSQL = "SELECT id, personId, image, TrainData, photoId,rectX,rectY,rectWidth,rectHeight FROM T_FACES WHERE id = ? ORDER BY id";
    
    if (sqlite3_prepare_v2(_db, SelectAllFaceSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, (int)faceId);
        while (sqlite3_step(statement) == SQLITE_ROW) {
            faceInfo = [[TTFaceInfo alloc]init];
            [faceInfo setId:sqlite3_column_int(statement, 0)];
            [faceInfo setPersonId:sqlite3_column_int(statement, 1)];
            [faceInfo setImage:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)]];
            
            if (loadTrainData) {
                    // First pull out the image into NSData
                int imageSize = sqlite3_column_bytes(statement, 3);
                NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 3) length:imageSize];
                [faceInfo setTrainData:imageData];
            }
            
            [faceInfo setPersonId:sqlite3_column_int(statement, 4)];
            [faceInfo setRectX:sqlite3_column_int(statement, 5)];
            [faceInfo setRectY:sqlite3_column_int(statement, 6)];
            [faceInfo setRectWidth:sqlite3_column_int(statement, 7)];
            [faceInfo setRectHeight:sqlite3_column_int(statement, 8)];
        }
    }
    
    sqlite3_finalize(statement);
    
    return faceInfo;
}

- (void)newPerson:(TTPersonInfo *)person
{
    if (person) {
        sqlite3_stmt *statement;
        const char *NewPersonSQL = "INSERT INTO T_PERSONS (ID, NAME, LinkFromContact, ShowFaceId, RelatedPhotosCount) VALUES (?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(_db, NewPersonSQL, -1, &statement, nil) == SQLITE_OK) {

            sqlite3_bind_int(statement, 1, (int)person.id);
            sqlite3_bind_text(statement, 2, [person.name UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 3, person.linkFromContact);
            sqlite3_bind_int(statement, 4, (int)person.showFaceId);
            sqlite3_bind_int(statement, 5, (int)person.relatedPhotosCount);
            sqlite3_step(statement);
        }
        
        sqlite3_finalize(statement);
    }
}

- (BOOL)updatePersonRelatedPhotosCount:(NSUInteger)personId
{
    TTPersonInfo * personInfo = [self getPerson:personId];
    
    if (personInfo) {
        sqlite3_stmt *statement;
        const char *UpdatePersonRelatedPhotosCountSQL = "UPDATE T_PERSONS set RelatedPhotosCount=RelatedPhotosCount+1 Where id = ? ";
        
        if (sqlite3_prepare_v2(_db, UpdatePersonRelatedPhotosCountSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)personId);
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)updatePersonName:(NSUInteger) personId name:(NSString *)name fromContact:(BOOL)fromContact
{
    TTPersonInfo * personInfo = [self getPerson:personId];
    if (personInfo){
        sqlite3_stmt *statement;
        const char *UpdatePersonNameSQL = "UPDATE T_PERSONS set name=?, linkFromContact=? Where id = ? ";
        
        if (sqlite3_prepare_v2(_db, UpdatePersonNameSQL, -1, &statement, nil) == SQLITE_OK) {
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

- (void)newFace:(TTFaceInfo *)face
{
    if (face) {
        sqlite3_stmt *statement;
        
        const char *NewFaceSQL = "INSERT INTO T_FACES (ID, PersonId, Image, TrainData, PhotoId,rectX,rectY,rectWidth,rectHeight,confidence) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
       
        if (sqlite3_prepare_v2(_db, NewFaceSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)face.id);
            sqlite3_bind_int(statement, 2, (int)face.personId);
            sqlite3_bind_text(statement, 3, [face.image UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_blob(statement, 4, face.trainData.bytes, (int)face.trainData.length, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 5, (int)face.photoId);
            sqlite3_bind_int(statement, 6, (int)face.rectX);
            sqlite3_bind_int(statement, 7, (int)face.rectY);
            sqlite3_bind_int(statement, 8, (int)face.rectWidth);
            sqlite3_bind_int(statement, 9, (int)face.rectHeight);
            sqlite3_bind_double(statement, 10, face.confidence);
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }

}

- (BOOL) executeUpdateSQL:(const char *)sql
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
    const char *DeleteAllPersonSQL = "DELETE FROM T_PERSONS ";
    return [self executeUpdateSQL:DeleteAllPersonSQL];
}


- (BOOL)deleteAllFaces
{
    const char *DeleteAllFaceSQL = "DELETE FROM T_FACES ";
    return [self executeUpdateSQL:DeleteAllFaceSQL];
}

- (BOOL)deleteAllPhotos
{
    const char *DeleteAllPhotoSQL = "DELETE FROM T_PHOTOS ";
    return [self executeUpdateSQL:DeleteAllPhotoSQL];
}

- (void)newPhoto:(TTPhotoInfo *)photo
{
    if (photo) {
        sqlite3_stmt *statement;
        const char *NewPhotoSQL = "INSERT INTO T_PHOTOS (ID, AbsoluteURL, TakeTime, Width, Height, Latitude, Longitude, Altitude) VALUES (?,?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(_db, NewPhotoSQL, -1, &statement, nil) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, (int)photo.id);
            sqlite3_bind_text(statement, 2, [photo.absoluteURL UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [photo.takeTime UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 4, photo.width);
            sqlite3_bind_int(statement, 5, photo.height);
            sqlite3_bind_double(statement, 6, photo.latitude);
            sqlite3_bind_double(statement, 7, photo.longitude);
            sqlite3_bind_double(statement, 8, photo.altitude);
            sqlite3_step(statement);
        }
        
        sqlite3_finalize(statement);
        
    }
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

-(void)newSequence:(NSString*)seqName {
    sqlite3_stmt *statement;
    const char *NewPhotoSQL = "INSERT INTO T_SEQ (NAME, NEXTVAL) VALUES (?, ?)";
    if (sqlite3_prepare_v2(_db, NewPhotoSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [seqName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2, 1);
        sqlite3_step(statement);
    }
    sqlite3_finalize(statement);
}

-(void)updateSequence:(NSString*)seqName {
    sqlite3_stmt *statement;
    const char *NewPhotoSQL = "UPDATE T_SEQ SET NEXTVAL = NEXTVAL +1 WHERE NAME=?";
    if (sqlite3_prepare_v2(_db, NewPhotoSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [seqName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
    }
    sqlite3_finalize(statement);
}

-(NSUInteger)getNextSeqId:(NSString*)seqName {
     // seqName exists
    const char *FindSeqSQL = "SELECT NAME, NEXTVAL FROM T_SEQ WHERE NAME=?";
    sqlite3_stmt *statement;
    
    int currentVal = 1;
    
    if (sqlite3_prepare_v2(_db, FindSeqSQL, -1, &statement, nil) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [seqName UTF8String], -1, SQLITE_TRANSIENT);
        BOOL exists = NO;
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            // exists
            exists = YES;
            currentVal = sqlite3_column_int(statement, 1);
            [self updateSequence:seqName];
        }
        
        sqlite3_finalize(statement);
        
        if (!exists) {
            [self newSequence:seqName];
        }
        
    }
    return currentVal;
}

- (NSUInteger)getNextFaceId {
    return [self getNextSeqId:@"SEQ_FACES"];
}

- (NSUInteger)getNextPhotoId {
    return [self getNextSeqId:@"SEQ_PHOTOS"];
}

- (NSUInteger)getNextPersonId {
    return [self getNextSeqId:@"SEQ_PERSONS"];
}

- (void)createTablesIfNeeded
{
        //AUTOINCREMENT
    const char *CreatePersonTableSQL = "CREATE TABLE IF NOT EXISTS T_PERSONS ('id' INTEGER NOT NULL PRIMARY KEY ,'name' VARCHAR,'linkFromContact' BOOL,'showFaceId' INTEGER, 'relatedPhotosCount' INTEGER)";
    
        //AUTOINCREMENT
    const char *CreateFaceTableSQL = "CREATE TABLE IF NOT EXISTS T_FACES ('id' INTEGER NOT NULL PRIMARY KEY  ,'personId' INTEGER,'image' VARCHAR,'TrainData' VARCHAR,'photoId' INTEGER, 'rectX' INTEGER, 'rectY' INTEGER, 'rectWidth' INTEGER, 'rectHeight' INTEGER, 'confidence' DOUBLE)";
    
        //AUTOINCREMENT
    const char *CreatePhotoTableSQL = "CREATE TABLE IF NOT EXISTS T_PHOTOS ('id' INTEGER NOT NULL PRIMARY KEY ,'absoluteURL' VARCHAR,'takeTime' VARCHAR,'width' INTEGER,'height' INTEGER,'latitude' DOUBLE,'longitude' DOUBLE,'altitude' DOUBLE)";
    
    const char *CreateSequenceTableSQL = "CREATE TABLE IF NOT EXISTS T_SEQ ('NAME' VARCHAR PRIMARY KEY, 'NEXTVAL' INTEGER)";
    
    if (sqlite3_exec(_db, CreatePersonTableSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Persons table could not be created.");
    }
    
    if (sqlite3_exec(_db, CreateFaceTableSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Faces table could not be created.");
    }
    
    if (sqlite3_exec(_db, CreatePhotoTableSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Photos table could not be created.");
    }
    
    if (sqlite3_exec(_db, CreateSequenceTableSQL, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"The Photos table could not be created.");
    }
    
    
}

@end
