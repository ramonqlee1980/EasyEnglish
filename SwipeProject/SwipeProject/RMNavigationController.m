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
-(void)setTitle:(NSString *)title
{
#define kTitleViewTag 10
    //reset duplicate one
    NSArray* subViews = [self.view subviews];
    for (UIView* titleSubview in subViews)
    {
        if (titleSubview && [titleSubview isKindOfClass:[UIButton class]] && titleSubview.tag==kTitleViewTag ) {
            [((UIButton*)titleSubview) setTitle:title forState:UIControlStateNormal];
            NSLog(@"reset title and return");
            return;
        }
    }
    
    UIButton*titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [titleView setFrame:CGRectMake(kMarginToBoundaryX+kDefaultButtonSize,kMarginToTopBoundary,kMiddleSpace,kDefaultButtonSize)];
    [titleView setTitle:title?title:kDefaultTitle forState:UIControlStateNormal];
    [titleView.titleLabel setFont:[UIFont boldSystemFontOfSize:kTitleFontSize]];
    titleView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleView setHidden:NO];
    [titleView setTag:kTitleViewTag];
    [self.view addSubview:titleView];
}
-(void)LeftButtonTouchDown:(UIView*)btn
{
    if (btn) {
        [self dismissModalViewControllerAnimated:YES];
    }
}
-(void)enableBackButton
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Back" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(LeftButtonTouchDown:)forControlEvents: UIControlEventTouchUpInside];
    //处理按钮松开状态
    [self setLeftBarButton:button];
}
@end
