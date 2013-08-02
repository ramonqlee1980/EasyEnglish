//
//  RMTextViewController.h
//  SwipeProject
//
//  Created by Ramonqlee on 7/24/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMTextViewController : UIViewController
@property(nonatomic,copy)NSString* mTitleString;
@property(nonatomic,copy)NSString* mTextString;

-(void)setText:(NSString*)text withTitle:(NSString*)title;
@end
