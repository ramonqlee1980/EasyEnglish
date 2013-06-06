//
//  RMNavigationViewController.h
//  SwipeProject
//
//  Created by Ramonqlee on 6/7/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMNavigationController : UIViewController

@property(nonatomic,retain) UIButton *leftBarButton;
@property(nonatomic,retain) UIButton *rightBarButton;

- (id)initWithRootViewController:(UIViewController *)rootViewController; 
@end
