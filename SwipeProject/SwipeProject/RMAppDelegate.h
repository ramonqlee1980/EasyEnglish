//
//  RMAppDelegate.h
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarViewController.h"

@class MiddleViewController;

@interface RMAppDelegate : UIResponder <UIApplicationDelegate,SideBarViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MiddleViewController *viewController;
@property(nonatomic,assign)SideBarViewController* sideBarController;

- (void)showSideBarControllerWithDirection:(SideBarShowDirection)direction;
@end
