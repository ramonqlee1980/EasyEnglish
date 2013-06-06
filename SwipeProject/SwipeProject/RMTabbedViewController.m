//
//  RMTabbedViewController.m
//  SwipeProject
//
//  Created by ramonqlee on 5/8/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMTabbedViewController.h"
#import "InfiniTabBar.h"
#import "RMTableViewController.h"
#import "RMAppDelegate.h"
#import "SettingsViewController.h"

#define kDefaultResouceUrl @"http://www.idreems.com/openapi/aster.php?type=shuangzi"


@interface RMTabbedViewController ()<InfiniTabBarDelegate,UITabbedTableViewDelegate>
{
    SideBarShowDirection direction;
}
@property(nonatomic,copy)NSString* mUrl;
@property(nonatomic,copy)NSString* mTitle;
@property(nonatomic,assign)InfiniTabBar* tabBar;
@property(nonatomic,assign)RMTableViewController* tableView;
@end

@implementation RMTabbedViewController
@synthesize tabBar;
@synthesize tableView;
@synthesize mUrl;
@synthesize mTitle;

-(id)init:(NSString*)url withTitle:(NSString*)title
{
    if (self = [super init]) {
        self.mUrl = url;
        self.mTitle = title;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    self.mUrl = nil;
    self.tabBar = nil;
    self.tableView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    direction = SideBarShowDirectionNone;
    
    //添加headbar
    UIImageView *headView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kNavigationBarBackground]];
    [headView setFrame:CGRectMake(0, 0, kDeviceWidth, kNavigationBarHeight)];
    [self.view addSubview:headView];
    [headView release];
    
    //topbar 的按钮
    UIButton* photobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photobtn setFrame:CGRectMake(kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [photobtn setBackgroundImage:[UIImage imageNamed:kLeftSideBarButtonBackground] forState:UIControlStateNormal];
    [photobtn addTarget:self action:@selector(showLeftSidebar:) forControlEvents:UIControlEventTouchUpInside];
    //    [photobtn setTag:FPhoto];
    [photobtn setHidden:NO];
    [self.view addSubview:photobtn];
    
    UIButton* leftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftViewBtn setFrame:CGRectMake(kMarginToBoundaryX+kDefaultButtonSize,kMarginToTopBoundary,kMiddleSpace,kDefaultButtonSize)];
    [leftViewBtn setTitle:self.mTitle?self.mTitle:kDefaultTitle forState:UIControlStateNormal];
    [leftViewBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kTitleFontSize]];
    leftViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftViewBtn addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [fourTypebtn setTag:FFourtype];
    [leftViewBtn setHidden:NO];
    [self.view addSubview:leftViewBtn];
    
    UIButton* settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setFrame:CGRectMake(kDeviceWidth-kDefaultButtonSize-kMarginToBoundaryX-kDefaultButtonSize-kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [settingBtn setImage:[UIImage imageNamed:kIconSetting] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [writebtn setTag:FWrite];
    [settingBtn setHidden:YES];
    [self.view addSubview:settingBtn];
    
    UIButton* rightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightViewBtn setFrame:CGRectMake(kDeviceWidth-kDefaultButtonSize-kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [rightViewBtn setImage:[UIImage imageNamed:kRightSideBarButtonBackground] forState:UIControlStateNormal];
    [rightViewBtn addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [writebtn setTag:FWrite];
    [rightViewBtn setHidden:NO];
    [self.view addSubview:rightViewBtn];
    
    //add tableview
    CGRect rc = [[UIScreen mainScreen]applicationFrame];
    rc.origin.y = kNavigationBarHeight;
    rc.origin.x = 0;
    rc.size.height = rc.size.height-kNavigationBarHeight;
    self.tableView = [[RMTableViewController alloc]initWithFrame:rc];
    [self.tableView setUrl:self.mUrl?self.mUrl:kDefaultResouceUrl];
    [self.view addSubview:tableView.view];
    self.tableView.delegate = self;
}
-(void)settingClick:(UIView*)sender
{
    SettingsViewController* controller = [[[SettingsViewController alloc]init]autorelease];
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)showLeftSidebar:(UIView*)sender
{
    RMAppDelegate* appDelegate = (RMAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showSideBarControllerWithDirection:SideBarShowDirectionLeft];
}
-(void)saveAsDefaultAster:(UIView*)sender
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];

    //already set?
    NSDictionary* dict = [setting objectForKey:kAsterName];
    if (dict) {
        if (NSOrderedSame==[self.mTitle compare:[dict objectForKey:kTitle]]) {
            [self showToast:[NSString stringWithFormat:@"当前星座已经为 %@，无需设置!",self.mTitle]];
            return;
        }
    }
    
    [setting setObject:[NSDictionary dictionaryWithObjectsAndKeys:self.mTitle, kTitle,self.mUrl,kUrl,nil] forKey:kAsterName];
    [setting synchronize];
    [self showToast:[NSString stringWithFormat:@"已将 %@ 设置为缺省星座!",self.mTitle]];
}
-(void)showToast:(NSString*)msg
{
    if ([self.view respondsToSelector:@selector(makeToast:)]) {
        
        [self.view performSelector:@selector(makeToast:) withObject:msg];
    }
}
-(void)BtnClicked:(UIView*)sender
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark InfiniTabBarDelegate
- (void)infiniTabBar:(InfiniTabBar *)tabBar didScrollToTabBarWithTag:(int)tag {
	//self.dLabel.text = [NSString stringWithFormat:@"%d", tag + 1];
}

- (void)infiniTabBar:(InfiniTabBar *)tabBar didSelectItemWithTag:(int)tag {
    //TODO::change to another channel
    [tableView setUrl:kDefaultResouceUrl];
}
#pragma mark UITabbedTableViewDelegate
- (void)didSelectRow:(UIViewController*)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}
@end
