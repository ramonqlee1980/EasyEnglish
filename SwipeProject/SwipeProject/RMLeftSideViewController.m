//
//  RMLeftSideViewController.m
//  SwipeProject
//
//  Created by ramonqlee on 5/4/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMLeftSideViewController.h"
#import "SideBarViewController.h"
#import "RMTabbedViewController.h"
#import "SettingsViewController.h"
#import "Flurry.h"

NSInteger kLeftChannelGroupCount = 3;
NSString*kLeftChannelGroupFormatter= @"LeftChannelGroup%d";

@interface RMLeftSideViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* items;
}
@end

@implementation RMLeftSideViewController
@synthesize delegate;

-(void)dealloc
{
    [items release];
    [super dealloc];
}
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
    
    if (!items) {
        items = [[NSMutableArray alloc]init];
    }
    //get group data
    for (NSInteger i = 0; i<kLeftChannelGroupCount; ++i) {
        NSArray* group = [self getGroup:[NSString stringWithFormat:kLeftChannelGroupFormatter,i+1] ofType:@"plist"];
        if (group && [group count]>0) {
            [items addObject:group];
        }
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    //添加headbar
    UIImageView *headView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kNavigationBarBackground]];
    [headView setFrame:CGRectMake(0, 0, kDeviceWidth, kNavigationBarHeight)];
    [self.view addSubview:headView];
    [headView release];
    
    //topbar 的按钮
    UIButton* photobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photobtn setFrame:CGRectMake(kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [photobtn setBackgroundImage:[UIImage imageNamed:kLeftSideBarButtonBackground] forState:UIControlStateNormal];
    [photobtn addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [photobtn setTag:FPhoto];
    [photobtn setHidden:YES];
    [self.view addSubview:photobtn];
    
    UIButton* leftViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftViewBtn setFrame:CGRectMake(kMarginToBoundaryX+kDefaultButtonSize,kMarginToTopBoundary,kMiddleSpace,kDefaultButtonSize)];
    //[leftViewBtn setTitle:self.mTitle?self.mTitle:kDefaultTitle forState:UIControlStateNormal];
    [leftViewBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:kTitleFontSize]];
    leftViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftViewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftViewBtn addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [fourTypebtn setTag:FFourtype];
    [leftViewBtn setHidden:YES];
    [self.view addSubview:leftViewBtn];
    
    UIButton* rightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightViewBtn setFrame:CGRectMake(kDeviceWidth-kDefaultButtonSize-kMarginToBoundaryX,kMarginToTopBoundary,kDefaultButtonSize,kDefaultButtonSize)];
    [rightViewBtn setImage:[UIImage imageNamed:kRightSideBarButtonBackground] forState:UIControlStateNormal];
    [rightViewBtn addTarget:self action:@selector(saveAsDefaultAster:) forControlEvents:UIControlEventTouchUpInside];
    //    [writebtn setTag:FWrite];
    [rightViewBtn setHidden:YES];
    [self.view addSubview:rightViewBtn];
    
    //add tableview
    CGRect rc = [[UIScreen mainScreen]applicationFrame];
    rc.origin.y = kNavigationBarHeight;
    rc.origin.x = 0;
    rc.size.height = rc.size.height-kNavigationBarHeight;
    rc.size.width = kDeviceWidth-kSideBarMargin;
    UITableView* tableView = [[[UITableView alloc]initWithFrame:rc style:UITableViewStyleGrouped]autorelease];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return items?([items count]):0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (items && [items count]>section) {
        NSArray* arr = [items objectAtIndex:section];
        return  arr?[arr count ]:0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSArray* currentItem = nil;
    if (items && [items count]>indexPath.section) {
        currentItem = [items objectAtIndex:indexPath.section];
    }
    
    NSDictionary* dict = [currentItem objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellStyleValue1;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString* text = [NSString stringWithFormat:@"%@",[dict objectForKey:kTitle]];
    NSString *path = [[NSBundle mainBundle] pathForResource:[dict objectForKey:kIcon] ofType:@"gif"];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        cell.imageView.image = image;
    }
    cell.textLabel.text = text;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSArray* currentItem = nil;
    if (items && [items count]>indexPath.section) {
        currentItem = [items objectAtIndex:indexPath.section];
    }
    NSDictionary* dict = [currentItem objectAtIndex:indexPath.row];
    if (delegate && [delegate respondsToSelector:@selector(leftSideBarSelectWithController:)])
    {
        NSString* title = [dict objectForKey:kTitle];
        [Flurry logEvent:title];
        [delegate leftSideBarSelectWithController:[self subViewController:[dict objectForKey:kUrl] withTitle:title]];
    }
    
    [tView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark viewcontrollers
-(UIViewController*)subViewController:(NSString*)url withTitle:(NSString*)title
{
    //kPopularMakeupIndex
    return [[[RMTabbedViewController alloc]init:url withTitle:title]autorelease];
}
-(void)settingClick:(UIView*)sender
{
    SettingsViewController* controller = [[[SettingsViewController alloc]init]autorelease];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark util methods
-(NSArray*)getGroup:(NSString *)name ofType:(NSString *)ext
{
    NSMutableArray* dataArray = [[[NSMutableArray alloc]init]autorelease];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (!data) {
        return dataArray;
    }
    
    [dataArray addObjectsFromArray:[data allValues]];
    
    //sort
    NSSortDescriptor * descriptor =[[[NSSortDescriptor alloc] initWithKey:kOrder ascending:YES comparator:^(id order1, id order2) {
        NSString* v1 = (NSString*)order1;
        NSString* v2 = (NSString*)order2;
        
        
        return [v1 intValue]>=[v2 intValue];
    }]autorelease];
    [dataArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSLog(@"%@", dataArray);//直接打印数据
    
    return dataArray;
}
@end
