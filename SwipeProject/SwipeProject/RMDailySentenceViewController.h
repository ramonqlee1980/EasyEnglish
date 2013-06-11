//
//  RMDailySentenceViewController.h
//  SwipeProject
//
//  Created by Ramonqlee on 6/3/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AudioButton;

@interface RMDailySentenceViewController : UIViewController
@property(nonatomic,retain)IBOutlet UIImageView* imageView;
@property(nonatomic,retain)IBOutlet UITextView* foreignTextView;
@property(nonatomic,retain)IBOutlet UITextView* chineseTextView;
@property(nonatomic,retain)IBOutlet AudioButton* audioButton;
@property(nonatomic,retain)IBOutlet UIButton* saveToLocalButton;
@property(nonatomic,retain)IBOutlet UIButton* shareButton;

-(IBAction)playAudio:(AudioButton *)button;
@end
