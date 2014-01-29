//
//  FIGPhotoDetailViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-29.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGPhotoViewController.h"
#import "FIGPhotoDetailViewControllerData.h"
#import "FIGImageScrollView.h"

@interface FIGPhotoViewController ()

@end

@implementation FIGPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
}

+ (FIGPhotoViewController *)photoViewControllerForPageIndex:(NSUInteger)pageIndex
{
    if (pageIndex < [[FIGPhotoDetailViewControllerData sharedInstance] photoCount])
    {
        return [[self alloc] initWithPageIndex:pageIndex];
    }
    return nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        _pageIndex = pageIndex;
    }
   
    return self;
}

- (void)loadView {
    // replace our view property with our custom image scroll view
    FIGImageScrollView *scrollView = [[FIGImageScrollView alloc] init];
    scrollView.index = _pageIndex;
    
    self.view = scrollView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set the navigation bar's title to indicate which photo index we are viewing,
    // note that our parent is MyPageViewController
    //
    self.parentViewController.navigationItem.title =
    [NSString stringWithFormat:@"%@ of %@", [@(self.pageIndex+1) stringValue], [@([[FIGPhotoDetailViewControllerData sharedInstance] photoCount]) stringValue]];
}

@end
