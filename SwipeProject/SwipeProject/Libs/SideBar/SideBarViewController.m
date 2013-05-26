//
//  SideBarViewController.m
//  SwipeToTransferDemo
//
//  Created by lijiangang on 13-4-18.
//  Copyright (c) 2013年 lijiangang. All rights reserved.
//

#import "SideBarViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface SideBarViewController ()<SiderBarDelegate>
@property (retain,nonatomic)UIViewController *leftSideBarViewController;
@property (retain,nonatomic)UIViewController *rightSideBarViewController;
@end

@implementation SideBarViewController
{
    UIViewController  *currentMainController;
    UITapGestureRecognizer *tapGestureRecognizer;
    UIPanGestureRecognizer *panGestureReconginzer;
    BOOL sideBarShowing;
    CGFloat currentTranslate;
}
static  SideBarViewController *rootViewCon;
#define ContentOffset   (kDeviceWidth-kSideBarMargin)
const int ContentMinOffset=60;
const float MoveAnimationDuration = 0.2;
@synthesize leftSideBarViewController;
@synthesize rightSideBarViewController;

+ (id)share
{
    return rootViewCon;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (rootViewCon) {
        rootViewCon = nil;
    }
    sideBarShowing = NO;
    currentTranslate = 0;
    _contentView.layer.shadowOffset = CGSizeMake(0, 0);
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentView.layer.shadowOpacity = 1;
    
    if(self.delegate)
    {
        self.leftSideBarViewController = [self.delegate leftViewController:self];
        self.rightSideBarViewController = [self.delegate rightViewController:self];
        [self middleViewController:[self.delegate middleViewController]];
    }
    
    //  [self addChildViewController:_leftSideBarViewController];
    if(self.rightSideBarViewController)
    {
        [self addChildViewController:self.rightSideBarViewController];
        [_navBackView addSubview:self.rightSideBarViewController.view];
    }
    
    if(self.leftSideBarViewController)
    {
        [_navBackView addSubview:self.leftSideBarViewController.view];
    }
    
    panGestureReconginzer  = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panInContentView:)];
    [self.contentView addGestureRecognizer:panGestureReconginzer];
}
- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction
{
    //bug fix:when sidebar show,just hide it
    if(sideBarShowing)
    {
        direction = SideBarShowDirectionNone;
    }
    
    if (direction!=SideBarShowDirectionNone) {
        UIView *view ;
        if (direction == SideBarShowDirectionLeft)
        {
            if (nil==self.leftSideBarViewController) {
                return;
            }
            view = self.leftSideBarViewController.view;
        }else
        {
            if(nil==self.rightSideBarViewController)
            {
                return;
            }
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
    }
    [self moveAnimationWithDirection:direction duration:MoveAnimationDuration];
}

- (void)middleViewController:(UIViewController *)controller
{
    if (currentMainController == nil) {
		controller.view.frame = self.contentView.bounds;
		currentMainController = controller;
		[self addChildViewController:currentMainController];
		[self.contentView addSubview:currentMainController.view];
		[currentMainController didMoveToParentViewController:self];
	}
}
- (void)leftSideBarSelectWithController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller setDelegate:self];
    }
    if (currentMainController == nil) {
		controller.view.frame = self.contentView.bounds;
		currentMainController = controller;
		[self addChildViewController:currentMainController];
		[self.contentView addSubview:currentMainController.view];
		[currentMainController didMoveToParentViewController:self];
	} else if (currentMainController != controller && controller !=nil) {
		controller.view.frame = self.contentView.bounds;
		[currentMainController willMoveToParentViewController:nil];
		[self addChildViewController:controller];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:currentMainController
						  toViewController:controller
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[currentMainController removeFromParentViewController];
									[controller didMoveToParentViewController:self];
									currentMainController = controller;
								}
         ];
	}
    
    [self showSideBarControllerWithDirection:SideBarShowDirectionNone];
}
- (void)rightSideBarSelectWithController:(UIViewController *)controller
{
    [self leftSideBarSelectWithController:controller];
}
- (void)panInContentView:(UIPanGestureRecognizer *)abc
{
    //bug fix:forbide pan in certain direction
    if (abc.state == UIGestureRecognizerStateBegan)
    {
        CGFloat translation = [abc translationInView:self.contentView].x;
        self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
        if (translation+currentTranslate>0)
        {
            if (nil==self.leftSideBarViewController) {
                [abc setTranslation:CGPointMake(0, 0) inView:self.contentView];
                return;
            }
        }else
        {
            if (nil==self.rightSideBarViewController) {
                [abc setTranslation:CGPointMake(0, 0) inView:self.contentView];
                return;
            }
        }
	}
    else if (abc.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translation = [abc translationInView:self.contentView].x;
        self.contentView.transform = CGAffineTransformMakeTranslation(translation+currentTranslate, 0);
        UIView *view ;
        if (translation+currentTranslate>0)
        {
            if (nil==self.leftSideBarViewController) {
                [abc setTranslation:CGPointMake(0, 0) inView:self.contentView];
                return;
            }
            view = self.leftSideBarViewController.view;
        }else
        {
            if (nil==self.rightSideBarViewController) {
                [abc setTranslation:CGPointMake(0, 0) inView:self.contentView];
                return;
            }
            view = self.rightSideBarViewController.view;
        }
        [self.navBackView bringSubviewToFront:view];
        
	} else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded)
    {
		currentTranslate = self.contentView.transform.tx;
        if (!sideBarShowing) {
            if (fabs(currentTranslate)<ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
            }else if(currentTranslate>ContentMinOffset)
            {
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }else
        {
            if (fabs(currentTranslate)<ContentOffset-ContentMinOffset) {
                [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
                
            }else if(currentTranslate>ContentOffset-ContentMinOffset)
            {
                
                [self moveAnimationWithDirection:SideBarShowDirectionLeft duration:MoveAnimationDuration];
                
            }else
            {
                [self moveAnimationWithDirection:SideBarShowDirectionRight duration:MoveAnimationDuration];
            }
        }
        
        
	}
    
    
}
- (void)moveAnimationWithDirection:(SideBarShowDirection)direction duration:(float)duration
{
    void (^animations)(void) = ^{
		switch (direction) {
            case SideBarShowDirectionNone:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
            }
                break;
            case SideBarShowDirectionLeft:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(ContentOffset, 0);
            }
                break;
            case SideBarShowDirectionRight:
            {
                self.contentView.transform  = CGAffineTransformMakeTranslation(-ContentOffset, 0);
            }
                break;
            default:
                break;
        }
	};
    void (^complete)(BOOL) = ^(BOOL finished) {
        self.contentView.userInteractionEnabled = YES;
        self.navBackView.userInteractionEnabled = YES;
        
        if (direction == SideBarShowDirectionNone) {
            
            if (tapGestureRecognizer) {
                [self.contentView removeGestureRecognizer:tapGestureRecognizer];
                tapGestureRecognizer = nil;
            }
            sideBarShowing = NO;
            
            
        }else
        {
            [self contentViewAddTapGestures];
            sideBarShowing = YES;
        }
        currentTranslate = self.contentView.transform.tx;
	};
    self.contentView.userInteractionEnabled = NO;
    self.navBackView.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:animations completion:complete];
}
- (void)contentViewAddTapGestures
{
    if (tapGestureRecognizer) {
        [self.contentView   removeGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer = nil;
    }
    
    tapGestureRecognizer = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapOnContentView:)];
    [self.contentView addGestureRecognizer:tapGestureRecognizer];
}
- (void)tapOnContentView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self moveAnimationWithDirection:SideBarShowDirectionNone duration:MoveAnimationDuration];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
