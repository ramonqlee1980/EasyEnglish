//
//  RMLeftSideViewController.h
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "JMStaticContentTableViewController.h"

@protocol SiderBarDelegate;

@interface RMLeftSideViewController : UIViewController
@property (assign,nonatomic)id<SiderBarDelegate>delegate;
@end
