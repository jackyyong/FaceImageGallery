//
//  FIGViewController.m
//  FaceImageGallery
//
//  Created by jacky on 14-1-26.
//  Copyright (c) 2014年 com.heraysoft. All rights reserved.
//

#import "TTRootViewController.h"
#import "TTRootLeftViewController.h"
#import "TTIndexCollectionViewController.h"
#import "TTCst.h"
#import "CRNavigationBar.h"
#import "CRNavigationController.h"

@interface TTRootViewController ()

@property(weak, nonatomic) UIViewController * centerViewController;
@property(weak, nonatomic) UIViewController * leftViewController;

@end

@implementation TTRootViewController

+ (UIImage *)defaultImage {
    return [UIImage imageNamed:GLOBAL_ACTION_NAV_LEFT_IMAGE];
}

-(UINavigationController*)embedInNavigationController:(UIViewController*)rootViewController {
    UINavigationController * navigationController = [[CRNavigationController alloc] initWithRootViewController:rootViewController];
    
    return navigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id) init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        UIColor * bgColor = [UIColor colorWithRed:34.0/255.0 green:72.0/255.0 blue:106.0/255.0 alpha:1.0];

        UINavigationController * centerController = [self embedInNavigationController: [[TTIndexCollectionViewController alloc] init]];
        
        [self setCenterPanel:centerController];
        
        centerController.navigationBar.barTintColor =bgColor;
        
        UINavigationController * leftController = [self embedInNavigationController: [[TTRootLeftViewController alloc] init]];
        
        leftController.navigationBar.barTintColor =bgColor;
        
        leftController.view.backgroundColor =bgColor;
        
        [self setLeftPanel:leftController];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     // 设置左边占比70%
    [self setLeftFixedWidth:GLOBAL_ROOT_LEFT_FIXED_WIDTH];
    [self setBouncePercentage:GLOBAL_ROOT_BOUNCE_PERCENTAGE];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
