//
//  RMDailySentenceViewController.m
//  SwipeProject
//
//  Created by Ramonqlee on 6/3/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMDailySentenceViewController.h"
#import "RMAppDelegate.h"
@interface RMDailySentenceViewController ()

@end

@implementation RMDailySentenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.navigationController) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(kBack, kBack) style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        self.navigationItem.rightBarButtonItem = backItem;
        [backItem release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark util methods
-(void)goBack:(UIView*)sender
{
    RMAppDelegate* appDelegate = (RMAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showSideBarControllerWithDirection:SideBarShowDirectionLeft];
}
@end
