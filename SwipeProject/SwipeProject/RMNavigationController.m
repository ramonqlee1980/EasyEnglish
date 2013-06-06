//
//  RMNavigationViewController.m
//  SwipeProject
//
//  Created by Ramonqlee on 6/7/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMNavigationController.h"


@interface RMNavigationController ()
@property(nonatomic,retain)UIViewController * rootViewController;
@end

@implementation RMNavigationController
@synthesize leftBarButton,rightBarButton,rootViewController;

-(void)setLeftBarButton:(UIButton *)leftBarButtonView
{
    //release 
    if (leftBarButton) {
        [leftBarButton removeFromSuperview];
        [leftBarButton release];
        leftBarButton = nil;
    }
    
    leftBarButton = leftBarButtonView;
    if(leftBarButtonView)
    {
        [leftBarButton retain];
        
        [leftBarButton setFrame:CGRectMake(kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
        //[leftBarButton setBackgroundImage:[UIImage imageNamed:kLeftSideBarButtonBackground] forState:UIControlStateNormal];
        
        [self.view addSubview:leftBarButton];
    }
}
-(void)setRightBarButton:(UIButton *)rightBarButtonView
{
    //release
    if (rightBarButton) {
        [rightBarButton removeFromSuperview];
        [rightBarButton release];
        rightBarButton = nil;
    }
    
    rightBarButton = rightBarButtonView;
    if(rightBarButton)
    {
        [rightBarButton retain];
        
        [rightBarButton setFrame:CGRectMake(kDeviceWidth-kDefaultButtonSize-kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
        //[rightBarButton setImage:[UIImage imageNamed:kRightSideBarButtonBackground] forState:UIControlStateNormal];
        
        [self.view addSubview:rightBarButton];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    self.rootViewController = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //添加headbar
    UIImageView *headView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kNavigationBarBackground]];
    [headView setFrame:CGRectMake(0, 0, kDeviceWidth, kNavigationBarHeight)];
    [self.view addSubview:headView];
    [headView release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (id)initWithRootViewController:(UIViewController *)rootViewCtrl
{
    if (!rootViewCtrl) {
        return self;
    }
    self.rootViewController = rootViewCtrl;
    
    //add rootview
    CGRect rc = [[UIScreen mainScreen]applicationFrame];
    rc.origin.y = kNavigationBarHeight;
    rc.origin.x = 0;
    rc.size.height = rc.size.height-kNavigationBarHeight;
    self.rootViewController.view.frame = rc;
    [self.view addSubview:self.rootViewController.view];
    
    return self;
}

@end
