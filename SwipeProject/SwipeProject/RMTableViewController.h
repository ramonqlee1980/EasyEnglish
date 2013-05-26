//
//  RMTableViewController.h
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UITabbedTableViewDelegate;

@interface RMTableViewController : UIViewController
-(id)initWithFrame:(CGRect)rc;
-(void)setUrl:(NSString*)url;
@property(nonatomic,retain)id<UITabbedTableViewDelegate> delegate;
@end
