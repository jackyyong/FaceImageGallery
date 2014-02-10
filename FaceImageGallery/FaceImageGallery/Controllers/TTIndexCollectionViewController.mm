//
//  TTFaceCollectionViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-2-5.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTIndexCollectionViewController.h"
#import "TTFaceModel.h"
#import "TTIndexCollectionViewCell.h"
#import "TTIndexCollectionViewDataSource.h"
#import "TTIndexCollectionViewFlowLayout.h"
#import "TTIndexCollectionViewDelegate.h"
#import "TTCst.h"
#import "TTImageProcessor.h"

@interface TTIndexCollectionViewController ()//<TTImageProcessorDelegate>

@property (nonatomic, strong) TTIndexCollectionViewDataSource *dataSource;
@property (nonatomic, strong) TTIndexCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) TTIndexCollectionViewDelegate *delegate;
@property (nonatomic, strong) TTImageProcessor *imageProcessor;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) NSInteger totalAssetCount;
@property (nonatomic, assign) NSInteger currentProcessIndex;

@end

@implementation TTIndexCollectionViewController

-(TTIndexCollectionViewDataSource *)dataSource{
    if(!_dataSource) {
        _dataSource = [[TTIndexCollectionViewDataSource alloc] init];
    }
    return _dataSource;
}

-(TTIndexCollectionViewDelegate *)delegate{
    if(!_delegate) {
        _delegate = [[TTIndexCollectionViewDelegate alloc] init];
    }
    return _delegate;
}

-(TTIndexCollectionViewFlowLayout *)flowLayout{
    if(!_flowLayout) {
        _flowLayout = [[TTIndexCollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

-(TTImageProcessor *)imageProcessor{
    if(!_imageProcessor) {
        _imageProcessor = [[TTImageProcessor alloc] init];
    }
    return _imageProcessor;
}

-(UILabel *)progressLabel{
    if(!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 20)];
        // INDEX_PROGRESS_LABEL_FORMAT
    }
    return _progressLabel;
}

-(UIProgressView *)progressView{
    if(!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 150, 320, 20)];
        // INDEX_PROGRESS_LABEL_FORMAT
    }
    return _progressView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id) init {
    self =  [super initWithCollectionViewLayout:self.flowLayout];
    
    if (self) {
        self.title = @"面孔";
        self.collectionView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background"]];
        
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNewAlbumFound:) name:EVENT_NEW_GROUP_FOUND object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNewAssetFound:) name:EVENT_NEW_ASSET_FOUND object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNewAssetProcessEnd:) name:EVENT_NEW_ASSET_PROCESS_END object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAlbumGroups:) name:ALAssetsLibraryChangedNotification object:nil];
    
    if (![self.imageProcessor isDatabaseCreated]) {
        // 异步处理整个相册
        dispatch_queue_t globalQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
        dispatch_async(globalQ, ^{
            
            [self.imageProcessor processAllLibrary];
            
        });
        
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        //[self.imageProcessor setDelegate:self];
    
    [self.collectionView setDataSource:self.dataSource];
    [self.collectionView setDelegate:self.delegate];
    
    [self.collectionView registerClass:[TTIndexCollectionViewCell class] forCellWithReuseIdentifier:INDEX_COLLECTION_REUSABLECellCELL_NAME];
    
    // 开始弹性动态效果
    self.collectionView.bounces = YES;
    // 不显示水平滚动指示器
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    // 不显示垂直滚动指示器
    [self.collectionView setShowsVerticalScrollIndicator:YES];
    
    [self.progressView setHidden:YES];
    [self.progressLabel setHidden:YES];
    
    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault];
    
    [self.view addSubview:self.progressLabel];
    [self.progressLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:self.progressView];
}

-(double) getCurrentProgress {
    return [[NSNumber numberWithInteger:self.currentProcessIndex] doubleValue]/[[NSNumber numberWithInteger:self.totalAssetCount] doubleValue];
}

//
-(void) reloadAlbumGroups :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        //Value is a set of NSURL objects identifying the assets that were updated.
        //NSSet * updateAssetsKey = [userInfo objectForKey:ALAssetLibraryUpdatedAssetsKey];
        //NSSet * insertedAssetGroupKey = [userInfo objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
        //NSSet * updatedAssetGroupKey = [userInfo objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
        //NSSet * deletedAssetGroupKey = [userInfo objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
        
        
    }
}


// 当发现新相册时, 调用此函数, 此函数处理新发现的相册
-(void) whenNewAlbumFound :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        ALAssetsGroup * group = [userInfo objectForKey:EVENT_NGF_ARG_GROUP];
        
        if (group) {
            if (self.progressLabel.hidden) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressLabel setHidden:NO];
                    [self.progressView setHidden:NO];
                });
            }
            
            [self setCurrentProcessIndex:0];
            [self setTotalAssetCount:[group numberOfAssets]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:self.getCurrentProgress];
                [self.progressLabel setText:[NSString stringWithFormat:INDEX_PROGRESS_LABEL_FORMAT, self.currentProcessIndex, self.totalAssetCount ]];
            });
        }
    }
}

-(void) whenNewAssetFound :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        ALAsset * asset = [userInfo objectForKey:EVENT_NSF_ARG_ASSET];
        
        if (asset) {
            if (self.progressLabel.hidden) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressLabel setHidden:NO];
                    [self.progressView setHidden:NO];
                    
                });
            }
            self.currentProcessIndex+=1;
        }
    }
}

    // 当发现新相册时, 调用此函数, 此函数处理新发现的相册
-(void) whenNewAssetProcessEnd :(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    if (userInfo) {
        ALAsset * asset = [userInfo objectForKey:EVENT_NSF_ARG_ASSET];
        
        if (asset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.currentProcessIndex == self.totalAssetCount) {
                    [self.progressLabel setHidden:YES];
                    [self.progressView setHidden:YES];
                    
                } else {
                    [self.progressView setProgress:self.getCurrentProgress];
                    [self.progressLabel setText:[NSString stringWithFormat:INDEX_PROGRESS_LABEL_FORMAT, self.currentProcessIndex, self.totalAssetCount ]];
                }
                
                [self.dataSource reloadData];
                [self.collectionView reloadData];
            });
        }
    }
}

- (void)viewDidUnload {
    [super viewDidLoad];
    
    [self.collectionView release];
    
}

- (void)dealloc {
    
    [self.collectionView release];
    
    [super dealloc];
}

@end
