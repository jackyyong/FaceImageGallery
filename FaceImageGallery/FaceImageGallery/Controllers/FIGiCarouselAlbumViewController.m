//
//  FIGiCarouselViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-30.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "FIGiCarouselAlbumViewController.h"
#include <AssetsLibrary/AssetsLibrary.h> 
#import "AssetsDataIsInaccessibleViewController.h"
#import "FXImageView.h"
#import "FIGAlbumReader.h"


@interface FIGiCarouselAlbumViewController ()

@property (nonatomic, strong) FIGAlbumReader *reader;
@end

@implementation FIGiCarouselAlbumViewController

@synthesize iCarouselView;


- (void)awakeFromNib
{
    
	if([self.reader getAlbumCount] > 0) {
        [self.reader removeAllAlbums];
    }
    
    [self.reader readAlbums];

}

-(FIGAlbumReader*) reader {
    if(!_reader) {
        _reader = [[FIGAlbumReader alloc] init];
    }
    
    return _reader;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)whenReaderSuccess {
    [self.iCarouselView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}


- (void)whenReaderFailture:(NSError *)error {
    AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"assetsDataIsInaccessibleViewController"];
    
    NSString *errorMessage = nil;
    switch ([error code]) {
        case ALAssetsLibraryAccessUserDeniedError:
        case ALAssetsLibraryAccessGloballyDeniedError:
            errorMessage = @"The user has declined access to it.";
            break;
        default:
            errorMessage = @"Reason unknown.";
            break;
    }
    
    assetsDataInaccessibleViewController.explanation = errorMessage;
    [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
}


- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    iCarouselView.delegate = nil;
    iCarouselView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.reader setDelegate:self];
        //configure carousel
    iCarouselView.type = iCarouselTypeCoverFlow2;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //free up memory by releasing subviews
    self.iCarouselView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.reader getAlbumCount];
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    
    NSLog(@"Current Index %lu ", index);
    
    FIGAlbumInfo* albumInfo = nil;
    
    if ([self.reader getAlbumCount] > index) {
         albumInfo = [self.reader getAlbumInfoAtIndex:index];
    }
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        imageView.cornerRadius = 10.0f;
        view = imageView;
    }
    
    //show placeholder
    ((FXImageView *)view).processedImage = [UIImage imageNamed:@"placeholder"];
    
    if (albumInfo) {
        //set image
        [((FXImageView *)view) setImage:[UIImage imageWithCGImage:albumInfo.posterImage]];
    }
  
    return view;
}



@end
