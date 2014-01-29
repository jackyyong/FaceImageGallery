//
//  FIGPhotoPageViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGPhotoPageViewController.h"
#import "FIGPhotoViewController.h"

@interface FIGPhotoPageViewController ()

@end

@implementation FIGPhotoPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // start by viewing the photo tapped by the user
    FIGPhotoViewController *startingPage = [FIGPhotoViewController photoViewControllerForPageIndex:self.startingIndex];
    
    if (startingPage != nil)
    {
        self.dataSource = self;
        
        [self setViewControllers:@[startingPage]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}


#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(FIGPhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [FIGPhotoViewController photoViewControllerForPageIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(FIGPhotoViewController *)vc
{
    NSUInteger index = vc.pageIndex;
    return [FIGPhotoViewController photoViewControllerForPageIndex:(index + 1)];
}

@end
