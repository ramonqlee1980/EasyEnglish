//
//  RMTabbedViewController.h
//  SwipeProject
//
//  Created by ramonqlee on 5/8/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITabbedTableViewDelegate <NSObject>
- (void)didSelectRow:(UIViewController*)controller;
@end

@interface RMTabbedViewController : UIViewController
-(id)init:(NSString*)url withTitle:(NSString*)title;
@end
