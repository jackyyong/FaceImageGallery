//
//  AssetsDataIsInaccessibleViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "AssetsDataIsInaccessibleViewController.h"

@interface AssetsDataIsInaccessibleViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

@implementation AssetsDataIsInaccessibleViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.messageTextView.text = self.explanation;
}


@end
