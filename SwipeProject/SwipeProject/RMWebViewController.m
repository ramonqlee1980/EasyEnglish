//
//  RMWebViewController.m
//  SwipeProject
//
//  Created by Ramonqlee on 7/29/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMWebViewController.h"

@interface RMWebViewController ()
{
    UIWebView * mTextView;
}
@end

@implementation RMWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setText:(NSString*)text withTitle:(NSString*)title
{
    self.mTextString = text;
    self.mTitleString = title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(!mTextView)
    {
        mTextView = [[UIWebView alloc]initWithFrame:self.view.bounds];
//        mTextView.font = [UIFont systemFontOfSize:kContentFontSize];
//        [mTextView setContentInset:UIEdgeInsetsMake(0, 0, kNavigationBarHeight, 0)];
//        mTextView.editable = NO;
    }
    
//    mTextView.text = self.mTextString;
    [mTextView loadHTMLString:self.mTextString baseURL:nil];
    
    self.title = self.mTitleString;
    
    
    [self.view addSubview:mTextView];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back",@"") style: UIBarButtonItemStyleBordered target: self action: @selector(back)];
    //newBackButton.tintColor = TintColor;
    [[self navigationItem] setLeftBarButtonItem:newBackButton];
    [newBackButton release];
}
-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [mTextView release];
    [super dealloc];
}

@end
