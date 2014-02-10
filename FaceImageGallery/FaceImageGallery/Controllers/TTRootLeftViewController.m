//
//  FIGLeftViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTRootLeftViewController.h"


@interface TTRootLeftViewController ()
@property (strong, nonatomic) UIButton * timelineButton;
@property (strong, nonatomic) UIButton * mapButton;
@property (strong, nonatomic) UIButton * facesButton;
@end

@implementation TTRootLeftViewController

-(UIButton*)facesButton {
    if (!_facesButton) {
        _facesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, 320, 60)];
        
        [_facesButton setImage:[UIImage imageNamed:@"Face_Sidebar_Face"] forState:UIControlStateNormal];
        [_facesButton setImage:[UIImage imageNamed:@"Face_Sidebar_Face_Selected"] forState:UIControlStateSelected];
        
        [_facesButton setSelected:YES];
    }
    return _facesButton;
}

-(UIButton*)timelineButton {
    if (!_timelineButton) {
        _timelineButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 140, 320, 60)];
        
        [_timelineButton setImage:[UIImage imageNamed:@"Face_Sidebar_Time"] forState:UIControlStateNormal];
        [_timelineButton setImage:[UIImage imageNamed:@"Face_Sidebar_Time_Selected"] forState:UIControlStateSelected];
        
    }
    return _timelineButton;
}

-(UIButton*)mapButton {
    if (!_mapButton) {
        _mapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, 320, 60)];
        
        [_mapButton setImage:[UIImage imageNamed:@"Face_Sidebar_Location"] forState:UIControlStateNormal];
        [_mapButton setImage:[UIImage imageNamed:@"Face_Sidebar_Location_Selected"] forState:UIControlStateSelected];
        
    }
    return _mapButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view addSubview:self.timelineButton];
    [self.view addSubview:self.mapButton];
    [self.view addSubview:self.facesButton];
    
    [self.facesButton addTarget:self
                         action:@selector(faceButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.timelineButton addTarget:self
                            action:@selector(timelineButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [self.mapButton addTarget:self
                       action:@selector(mapButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)faceButtonClicked:(id)sender {
    [self.facesButton setSelected:YES];
    [self.timelineButton setSelected:NO];
    [self.mapButton setSelected:NO];
    
}

-(void)timelineButtonClicked:(id)sender {
    [self.facesButton setSelected:NO];
    [self.timelineButton setSelected:YES];
    [self.mapButton setSelected:NO];
    
}

-(void)mapButtonClicked:(id)sender {
    [self.facesButton setSelected:NO];
    [self.timelineButton setSelected:NO];
    [self.mapButton setSelected:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
