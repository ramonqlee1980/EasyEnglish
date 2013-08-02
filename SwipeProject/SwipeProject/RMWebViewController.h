//
//  RMWebViewController.h
//  SwipeProject
//
//  Created by Ramonqlee on 7/29/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMWebViewController : UIViewController
@property(nonatomic,copy)NSString* mTitleString;
@property(nonatomic,copy)NSString* mTextString;

-(void)setText:(NSString*)text withTitle:(NSString*)title;
@end
