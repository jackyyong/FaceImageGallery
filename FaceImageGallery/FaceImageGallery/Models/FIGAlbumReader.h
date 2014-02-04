//
//  FIGAlbumReader.h
//  FaceImageGallery
//
//  Created by jacky on 14-2-1.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FIGAlbumInfo.h"

#include <AssetsLibrary/AssetsLibrary.h>

@interface NSObject(FIGAlbumReaderDelegate)

- (void)whenReaderFailture:(NSError *)error;

- (void)whenReaderSuccess;

@end

@interface FIGAlbumReader : NSObject
 
// 相册
@property (nonatomic, strong) NSMutableArray *albums;

- (void)setDelegate:(id)delegate;

-(id)initWithAlbumTypes: (NSInteger) groupTypes;

//读取所有相册信息, 该方法为异步方法
-(void)readAlbums;

// 删除所有相册
-(void)removeAllAlbums;

//获取相册数量
-(NSInteger)getAlbumCount;

//获取相册信息
-(FIGAlbumInfo *)getAlbumInfoAtIndex:(NSInteger) index;

@end
