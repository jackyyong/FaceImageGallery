//
//  FaceImageGalleryTests.m
//  FaceImageGalleryTests
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TTImageProcessor.h"
@interface FaceImageGalleryTests : XCTestCase

@property (nonatomic, strong) TTImageProcessor *processor;

@end

@implementation FaceImageGalleryTests

-(TTImageProcessor*) processor {
    if(!_processor) {
        _processor = [[TTImageProcessor alloc] init];
    }
    
    return _processor;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [self.processor processAllLibrary];
}

@end
