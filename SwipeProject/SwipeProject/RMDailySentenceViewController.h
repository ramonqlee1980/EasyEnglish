//
//  RMDailySentenceViewController.h
//  SwipeProject
//
//  Created by Ramonqlee on 6/3/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMDailySentenceViewController : UIViewController
@property(nonatomic,retain)IBOutlet UIImageView* imageView;
@property(nonatomic,retain)IBOutlet UITextView* foreignTextView;
@property(nonatomic,retain)IBOutlet UITextView* chineseTextView;
@property(nonatomic,retain)IBOutlet UIButton* audioButton;
@property(nonatomic,retain)IBOutlet UIButton* saveToLocalButton;
@property(nonatomic,retain)IBOutlet UIButton* shareButton;
@end
