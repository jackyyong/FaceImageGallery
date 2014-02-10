//
//  TTIndexCollectionViewLayoutAttributes.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-6.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewLayoutAttributes.h"

@implementation TTIndexCollectionViewLayoutAttributes


- (id)init
{
    self = [super init];
    if (self) {
        _headerTextAlignment = NSTextAlignmentLeft;
        _shadowOpacity = 0.5;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TTIndexCollectionViewLayoutAttributes *newAttributes = [super copyWithZone:zone];
    newAttributes.headerTextAlignment = self.headerTextAlignment;
    newAttributes.shadowOpacity = self.shadowOpacity;
    return newAttributes;
}


@end
