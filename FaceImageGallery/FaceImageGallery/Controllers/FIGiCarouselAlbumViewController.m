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

@interface FIGiCarouselAlbumViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@end

@implementation FIGiCarouselAlbumViewController

@synthesize iCarouselView;

-(ALAssetsLibrary *) assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

-(NSMutableArray *) groups{
    if (!_groups) {
        _groups = [[NSMutableArray alloc] init];
    }
    return _groups;
}

- (void)awakeFromNib
{
   
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
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
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
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
        }
        else
        {
            [self.iCarouselView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    
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
    //return the total number of items in the carousel
    return [self.groups count];
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    ALAssetsGroup *groupForCell = self.groups[index];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        
        ((UIImageView *)view).image = posterImage;
        
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    
    return view;
}



@end
