//
//  FIGViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGRootViewController.h"

@interface FIGRootViewController ()

@end

@implementation FIGRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void) awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"naviagtionLeftViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"navigationCenterViewController"]];
    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"navigationRightViewController"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
