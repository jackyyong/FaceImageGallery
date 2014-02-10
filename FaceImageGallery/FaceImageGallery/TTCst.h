//
//  TTIndexCst.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRAIN_FACE_WIDTH 336
#define TRAIN_FACE_HEIGHT 336

#define INDEX_BACKGROUND @"Background"

#define INDEX_COLLECTION_REUSABLECellCELL_NAME @"faceIndexCollectionViewCell"

#define INDEX_BACKGROUND_IMAGE @"Face_Background_White"

#define INDEX_TOTAL_PERPAGE 15
#define INDEX_TOTAL_PERROW 3
#define INDEX_FACE_WIDTH 200
#define INDEX_FACE_HEIGHT 200

#define GLOBAL_ACTION_NAV_LEFT_IMAGE @"Left_Nav"

#define GLOBAL_ROOT_LEFT_FIXED_WIDTH 210
#define GLOBAL_ROOT_BOUNCE_PERCENTAGE 0.3

#define NIB_NAME_ROOT_CONTROLLER @"RootViewController"
#define NIB_NAME_ROOT_CENTER_CONTROLLER @"RootCenterViewController"
#define NIB_NAME_ROOT_LEFT_CONTROLLER @"RootLeftViewController"


#define INDEX_PROGRESS_LABEL_FORMAT @"Processing %ld of %ld"
//使用全尺寸照片进行处理
#define USE_FULL_RESOLUTION_IMAGE YES

#define EVENT_NEW_GROUP_FOUND          @"NewGroupFound"
#define EVENT_NGF_ARG_GROUP            @"albumGroup"

#define EVENT_NEW_ASSET_FOUND          @"NewAssetFound"
#define EVENT_NSF_ARG_ASSET            @"asset"

#define EVENT_NEW_ASSET_PROCESS_END    @"NewAssetProcessEnd"
#define EVENT_NAPE_ARG_ASSET           @"asset"

#define EVENT_NEW_PERSON_FOUND         @"NewPersonFound"
#define EVENT_NPF_ARG_PERSONID         @"PersonId"

#define EVENT_NEW_FACE_FOUND           @"NewFaceFound"
#define EVENT_NFF_ARG_FACEID           @"FaceId"

